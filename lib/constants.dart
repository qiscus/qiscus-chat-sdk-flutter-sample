// ignore: constant_identifier_names
const APP_ID = 'sdksample';

class HeroTags {
  static const accountAvatar = 'account-avatar';
  static String roomAvatar({required int roomId}) {
    return 'room-avatar-$roomId';
  }

  static String roomName({required String roomName}) {
    return 'room-name-$roomName';
  }
}
