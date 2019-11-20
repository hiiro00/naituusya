

App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->
    console.log("接続開始")
    # Called when the subscription is ready for use on the server

  disconnected: ->
    console.log("接続失敗")
    # Called when the subscription has been terminated by the server

  received: (data) ->
    console.log('chat#received処理開始')
    console.log(data)
    mesg = data['message']
    
    if document.getElementById('message-list') != null
      console.log('システムメッセージ処理開始')
      li = document.createElement('li')
      li.textContent = mesg
      document.getElementById('message-list').appendChild(li)
      date_obj = new Date();
      document.getElementById('sys_message').innerHTML = "<p>更新しました　#{date_obj.toString()}</p>";
      # console.log("hoge")
    
    #　部屋画面
    if document.getElementById('show_room_mem') != null
      
      console.log('部屋画面向け処理開始')
      console.log(data)
      
      # 通知のroomNumと自分のroomNumが一致している場合
      if document.getElementById('show_Room_Num').textContent == data['roomNum']
        console.log('room_num.textContent 一致')
        
        # 部屋に参加　通知の場合
        if(mesg == "room_controlle_join")
          console.log('room_controlle_join 一致')
          memlist = document.getElementById('show_room_mem')
          memlist_span = memlist.getElementsByTagName('span')
          
          # リストに一致するものが一個もないか全件検索にて確認
          rslt_hit = false
          for d,i in memlist_span
            if d.textContent == data['name']
              rslt_hit = true
              return
          
          # リストに一致するものがない為、追加
          if rslt_hit == false
            span = document.createElement('span')
            span.textContent = data['name']
            span.setAttribute("class", "label label-default")
            span.setAttribute("style", "color: white; background-color: #428bca; margin: 2px;")
            document.getElementById('show_room_mem').appendChild(span)
        
        # 部屋から抜ける　通知の場合
        if(mesg == "room_controlle_logout")
          console.log('room_controlle_logout 一致')
          memlist = document.getElementById('show_room_mem')
          memlist_span = memlist.getElementsByTagName('span')
          
          for d,i in memlist_span
            if d.textContent == data['name']
              memlist.removeChild d
              return

        # 村　開始モーダル表示
        if(mesg == "show_village")
          console.log("show_village文を通った")
          
          # 自分がmemberの時のみ表示
          if $('#showvil_datatag').data('position') == "member"
            $('#modal_start_vil').modal('show')
            $('#showvil_datatag').data('roomNum',data['roomNum']);
            $('#showvil_datatag').data('villageNum',data['villageNum']);


        # 部屋　クローズ
        if(mesg == "room_controlle_close")
          console.log("room_controlle_close文を通った")
          
          # 自分がmemberの時のみ表示
          if $('#showvil_datatag').data('position') == "member"
            $('#modal_close_room').modal('show')
        
        # 村　開始失敗モーダル表示　人数不足
        if(mesg == "err_createVlg_lackmember")
          console.log("err_createVlg_lackmember文を通った")
          
          # owner
          if $('#showvil_datatag').data('position') == "owner"
            $('#modal_err_createVlg_lackmember').modal('show')
        



  put_message: (msg) ->
    @perform('put_message', { message: msg })
    
  join_room: (msg) ->
    @perform('join_room', { message: msg , roomNum: 3 , villageNum: 39 })
  
