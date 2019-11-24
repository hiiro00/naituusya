class VillagesController < ApplicationController
  before_action :authenticate_user!
  
  def create
    logger.debug("Village#createに入りました")
    logger.debug(params)
    
    # villageNumのユニーク値算出
    max = Village.maximum(:villageNum)
    if max.nil?
    	villageNumOrd = 1
    else
    	villageNumOrd = max + 1
    end
    
    # お題　作成
    theme = Theme.where( 'id >= ?', rand(Theme.first.id..Theme.last.id) ).first.content
    
    ## 村　配役構築
    # 村メンバー算出
    @rooms = Room.all
    
    @roomNum = []
    @ownName = []
    @memberTxt = []

    @roomNum,@ownName,@memberTxt = getRoomnumOwnnameMembertxt
    
    # logger.debug("params[:roomNum] #{params[:roomNum]}")
    # logger.debug("@roomNum #{@roomNum}")
    # logger.debug("@ownName #{@ownName}")
    # logger.debug("@memberTxt #{@memberTxt}")
    
    @showRoomNum,@showOwnName,@showMemberTxt = getShowRoomnumOwnnameMembertxt(params[:roomNum].to_i,@roomNum,@ownName,@memberTxt)
    
    logger.debug("@showMemberTxt: #{@showMemberTxt}")
    
    # 村作成条件　チェック
    if @showMemberTxt.nil?
      logger.debug("メンバー０名で作成できず")
      ChatChannel.broadcast_to('message', {"message"=>"err_createVlg_lackmember", "roomNum"=>params[:roomNum], "action"=>"err_createVlg_lackmember"})
      return
    end
    
    
    @villageMember =[]
    @villageMember = @showMemberTxt.split(",")
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
    
    logger.debug("@roomを表示")
    logger.debug(@room)
    @roomId = @room.id
    @roomNum = params[:roomNum].to_i
    logger.debug(@roomId)
    logger.debug(@roomNum)
    

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



  # 表示向けデータ作成(一覧)
  def getRoomnumOwnnameMembertxt
  	@roomNum = []
  	@ownName = []
  	@memberTxt = []
  
  	@rooms.each do |room|
  		if room.position == "owner"
  		  @roomNum.push(room.roomNum)
  		  @ownName.push(room.name)
  		  @memberTxt.push(nil)
  		end
  	end
  
  	@rooms.each do |room|
  		if room.position == "member"
  		  index = @roomNum.index(room.roomNum)
  		  
  		  if @memberTxt[index] == nil
  		    @memberTxt[index] = room.name
  		  else
  		    @memberTxt[index] = @memberTxt[index] + "," + room.name
  		  end
  		end
  	end
  
  	return @roomNum,@ownName,@memberTxt
  end
  
  # 表示向けデータ作成(部屋個別)
  def getShowRoomnumOwnnameMembertxt(roomNum ,roomNumA ,ownNameA ,memberTxtA)
      # logger.debug("getShowRoomnumOwnnameMembertxtに入りました")
      # logger.debug("roomNum=#{roomNum.class}")
      # 自身のroomNumと一致する配列添字を算出
      aryNum = 0
      # logger.debug("roomNumA.each_with_indexループ開始　")
      roomNumA.each_with_index do |room , i|
        # logger.debug("i=#{i} , room=#{room}")
        if room == roomNum
          # logger.debug("room == roomNum 条件成立 #{roomNum}")
          aryNum = i
          break
        end
      end
      
      # logger.debug("aryNum= #{aryNum}")
      
      showRoomNum   = roomNumA[aryNum]
      showOwnName   = ownNameA[aryNum]
      showMemberTxt = memberTxtA[aryNum]
      
      return showRoomNum,showOwnName,showMemberTxt
  end




end
