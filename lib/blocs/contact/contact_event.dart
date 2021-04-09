import 'package:equatable/equatable.dart';
import 'package:nmobile/model/entity/contact.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object> get props => [];
}

class LoadContactListEvent extends ContactEvent {
  final List<String> addressList;
  const LoadContactListEvent(this.addressList);
}

class LoadContactInfoEvent extends ContactEvent {
  final String address;
  const LoadContactInfoEvent(this.address);
}

class RefreshContactInfoEvent extends ContactEvent{
  final String address;
  const RefreshContactInfoEvent(this.address);
}

class UpdateUserInfoEvent extends ContactEvent {
  final ContactSchema userInfo;
  const UpdateUserInfoEvent(this.userInfo);
}
