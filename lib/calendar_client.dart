class CalendarClient {
  // For storing the CalendarApi object, this can be used
  // for performing all the operations
  static var calendar;

  // For creating a new calendar event
  Future<Map<String, String>> insert({
    @required required String title,
    @required String description,
    @required String location,
    @required List<EventAttendee> attendeeEmailList,
    @required bool shouldNotifyAttendees,
    @required bool hasConferenceSupport,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {}