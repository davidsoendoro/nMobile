

import 'package:bloc/bloc.dart';
import 'package:nmobile/blocs/message/message_event.dart';
import 'package:nmobile/blocs/message/message_state.dart';
import 'package:nmobile/model/entity/MessageListModel.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  @override
  MessageState get initialState => DefaultMessageState();

  @override
  Stream<MessageState> mapEventToState(MessageEvent event) async* {
    if (event is FetchMessageListEvent) {
      List<MessageListModel> messageList = await MessageListModel.getLastMessageList(event.start, 20);
      messageList.sort((a, b) => a.isTop
          ? (b.isTop ? -1 /*hold position original*/ : -1)
          : (b.isTop
          ? 1
          : b.lastReceiveTime.compareTo(a.lastReceiveTime)));
      yield FetchMessageListState(messageList,event.start);
    }
    else if (event is FetchMessageListEndEvent){
      yield FetchMessageListEndState();
    }
  }
}
