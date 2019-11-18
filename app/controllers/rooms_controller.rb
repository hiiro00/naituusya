class RoomsController < ApplicationController
  before_action :authenticate_user!
    def create
      logger.debug("createに入りました")
      logger.debug(params)
    	max = Room.maximum(:roomNum)
    	if max.nil?
    		roomNumOrd = 1
    	else
    		roomNumOrd = max + 1
    	end
    	
    	p roomNumOrd
    
    	@room = Room.new(name:params[:name],position:"owner",roomNum:roomNumOrd)
    	@room.save
    	redirect_to @room
    end
    
    def index
      # roomDBの異常値チェック
      # roomNum:Nilがあった場合は削除
      Room.where(roomNum: nil).delete_all
      
      # 部屋の過去データ削除処理　今後記載予定
      
      
      # 村の過去データ削除処理　今後記載予定
      
      
      @rooms = Room.all
      
      @roomNum = []
      @ownName = []
      @memberTxt = []
      
      @roomNum,@ownName,@memberTxt = getRoomnumOwnnameMembertxt
      
      #　配列順序　逆順へ
      @roomNum.reverse!
      @ownName.reverse!
      @memberTxt.reverse!

    end
    
    
    def join
      logger.debug("joinに入りました")
      logger.debug(params)
      
      # 参加した部屋がない場合
      if Room.where(roomNum: params[:roomNum]).blank?
        redirect_to action: 'index'
        return
      end
      
      
      # 存在しない場合は、追加する
      if Room.where(name: params[:name]).where(roomNum: params[:roomNum]).blank?
        @room = Room.new(name: params[:name],position:"member",roomNum: params[:roomNum])
        
      	@room.save
      else # すでに存在する場合は追加しない
        @roomTmp = Room.where(name: params[:name]).where(roomNum: params[:roomNum])
        @room = @roomTmp[0]
      end
      
      if @room.position == "member"
        ChatChannel.broadcast_to('message', {"message"=>"room_controlle_join", "roomNum"=>params[:roomNum], "name"=>params[:name],  "action"=>"join_room"})
      end
      
    	redirect_to @room
    end
    
    def room_out
      logger.debug("rooms#room_outに入りました")
      logger.debug(params)
      
      if Room.where(id: params[:roomId]).empty?
        # nilの時は、なにも処理しない
      else
        @room = Room.find(params[:roomId])
        @brcst_roomNum = @room.roomNum.to_s # バッチ処理のため、外部変数が必要
        @brcst_name = @room.name            # バッチ処理のため、外部変数が必要
        
        if @room.position == 'owner'
          ChatChannel.broadcast_to('message', {"message"=>"room_controlle_close", "roomNum"=>@brcst_roomNum, "name"=>@brcst_name,  "action"=>"logout_room"})
        else
          ChatChannel.broadcast_to('message', {"message"=>"room_controlle_logout", "roomNum"=>@brcst_roomNum, "name"=>@brcst_name,  "action"=>"logout_room"})
        end
        
        Room.where(id: params[:roomId]).delete_all
      end
      
      redirect_to action: 'index'
    end
    
    
    
    def judge
      logger.debug("judgeに入りました")
      logger.debug(params)
    end
    

    
    def show
      logger.debug("rooms#showに入りました")
      logger.debug(params)
      
      @room = Room.find(params[:id])

      # indexと同じ処理
      @rooms = Room.all
      
      @roomNum = []
      @ownName = []
      @memberTxt = []
      @showMemberTxtAry = []
      
      @roomNum,@ownName,@memberTxt = getRoomnumOwnnameMembertxt
      @showRoomNum,@showOwnName,@showMemberTxt,@showMemberTxtAry = getShowRoomnumOwnnameMembertxt(@room.roomNum,@roomNum,@ownName,@memberTxt)
      
      logger.debug("@showMemberTxt:")
      logger.debug(@showMemberTxt)
      

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
  		  
  		  # エラーケースへの自浄行動
  		  if @roomNum.index(room.roomNum).nil?
  		    logger.debug("★★エラー！！！memberは存在するが、ownerが存在しない　自浄作業が必要な状況")
  		    Room.where(id: room.id).delete_all
  		  else
    		  index = @roomNum.index(room.roomNum)
    		  # logger.debug("room.id=#{room.id}")
    		  # logger.debug("index=#{index}")
    		  # logger.debug("@memberTxt=#{@memberTxt}")
    		  
    		  if @memberTxt[index] == nil
    		    @memberTxt[index] = room.name
    		  else
    		    @memberTxt[index] = @memberTxt[index] + "," + room.name
    		  end  		    

  		  end
  		end
  	end
  
  	return @roomNum,@ownName,@memberTxt
  end
  
  # 表示向けデータ作成(部屋個別)
  def getShowRoomnumOwnnameMembertxt(roomNum ,roomNumA ,ownNameA ,memberTxtA)
      # 自身のroomNumと一致する配列添字を算出
      aryNum = 0
      roomNumA.each_with_index do |room , i|
        if room == roomNum
          aryNum = i
          break
        end
      end
      
      showRoomNum   = roomNumA[aryNum]
      showOwnName   = ownNameA[aryNum]
      showMemberTxt = memberTxtA[aryNum]
      
      if showMemberTxt.nil?
        showMemberTxtAry = []
      else
        showMemberTxtAry = showMemberTxt.split(",")
      end
      
      return showRoomNum,showOwnName,showMemberTxt,showMemberTxtAry
  end
    
    
    
end
