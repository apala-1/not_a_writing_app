class ChatVmArgs {
  final String myUserId;
  final String otherUserId;

  const ChatVmArgs({required this.myUserId, required this.otherUserId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatVmArgs &&
          runtimeType == other.runtimeType &&
          myUserId == other.myUserId &&
          otherUserId == other.otherUserId;

  @override
  int get hashCode => Object.hash(myUserId, otherUserId);
}