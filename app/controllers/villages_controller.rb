class VillagesController < ApplicationController
  before_action :authenticate_user!
  
  def create
    logger.debug("Village#createに入りました")
    logger.debug(params)
    
    # 村テーブルメンテ　24h以上前の村を削除
    Village.where('created_at <= ?', 24.hour.ago).delete_all
    
    # villageNumのユニーク値算出
    villageNumOrd = Village.createVillageNum
    
    # お題　作成
    theme = Theme.where( 'id >= ?', rand(Theme.first.id..Theme.last.id) ).first.content
    
    ## 村　配役構築
    # 村メンバー算出
    @showRoomNum,@showOwnName,@showMemberTxt = Room.getRoomShowText(params[:roomNum].to_i)

    # 村作成条件　チェック
    if @showMemberTxt.blank?
      logger.debug("メンバー０名で作成できず")
      # prm = "$('#modal_err_createVlg_lackmember').modal('show')"
      # render :js => prm
      # render "rooms/show"
      
      # pram2 = "window.location = '$('#modal_err_createVlg_lackmember').modal('show')'"
      # render :js => pram2
      #render js: "alert('Hello Rails');"
      
      ChatChannel.broadcast_to('message', {"message"=>"err_createVlg_lackmember", "roomNum"=>params[:roomNum], "action"=>"err_createVlg_lackmember"})
      return
    end
    
    # 村メンバー　リスト　作成
    @villageMember = @showMemberTxt
    @villageMember.push(@showOwnName)

    logger.debug("村メンバー：")
    logger.debug(@villageMember)

    # GM役、内通者役の配列番号　抽選
    max = @villageMember.count
    gmnaituu = (0..(max-1)).to_a.sort_by{rand}[0..1]
    logger.debug(gmnaituu[0])
    logger.debug(gmnaituu[1])

    # Villageテーブルを更新
    @villageMember.each_with_index do |village , i|
      if i == gmnaituu[0] # GM役
        position = "GM"
      elsif i == gmnaituu[1] # 内通者役
        position = "内通者"
      else
        position = "村人"
      end
      
      @village = Village.new(roomNum: params[:roomNum] , villageNum: villageNumOrd , name: @villageMember[i] , position: position , theme: theme)
      @village.save
    
    end
    
    ChatChannel.broadcast_to('message', {"message"=>"show_village", "roomNum"=>params[:roomNum], "villageNum"=> villageNumOrd ,"action"=>"show_village"})

    redirect_to action: 'show' , villageNum: villageNumOrd , roomNum: params[:roomNum]  # name: params[:name] , roomId: params[:roomId] , 
  end
  
  # 村開始時に、部屋画面にいなかったメンバーへの再送通知（村開始）
  def resend_show_village
    logger.debug("Village#resend_show_villageに入りました")
    logger.debug(params)
  
    ChatChannel.broadcast_to('message', {"message"=>"show_village", "roomNum"=>params[:roomNum], "villageNum"=> params[:villageNum] ,"action"=>"show_village"})

  end
  
  # ゲーム結果を全員に通知する
  def notif_result_village
    logger.debug("Village#notif_result_villageに入りました")
    logger.debug(params)
    
    @village = Village.where(villageNum: params[:villageNum].to_i).where(position: "内通者").first
    msg = "<h1>内通者：#{@village.name}<br>  お題：#{@village.theme}</h1>"
  
    ChatChannel.broadcast_to('message', {"message"=>"notif_result", "roomNum"=>params[:roomNum], "villageNum"=> params[:villageNum],"resultMsg"=>msg})

  end
  
  
  
  
  def show
    # params villageNum: villageNumOrd , roomNum: params[:roomNum]
    logger.debug("Village#showに入りました")
    logger.debug(params)

    @room = Room.where(name: current_user.name).where(roomNum: params[:roomNum].to_i)[0]
    @roomId = @room.id
    @roomNum = params[:roomNum].to_i

    @village = Village.where(villageNum: params[:villageNum].to_i).where(name: current_user.name)[0]
  end
  
  
  
  def modal_trigger_show
    logger.debug("Village#modal_trigger_showに入りました")
    logger.debug(params)

    # redirect_to action: 'show' , villageNum: params[:villageNum].to_i , roomNum: params[:roomNum].to_i
    pram = '?villageNum=' + params[:villageNum] + '&roomNum=' + params[:roomNum] + '\''
    pram2 = "window.location = '/villages/show" +  pram
    
    logger.debug(pram2)
    
    render :js => pram2
    
  end



end
