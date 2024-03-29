import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarClient {
  // For storing the CalendarApi object, this can be used
  // for performing all the operations
  static var calendar;
  Event event = Event();

  void createConference(bool hasConferenceSupport, DateTime startTime, DateTime endTime){
    if (hasConferenceSupport && event.conferenceData == null) {
      ConferenceData conferenceData = ConferenceData();
      CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
      conferenceRequest.requestId =
      "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
      conferenceData.createRequest = conferenceRequest;

      event.conferenceData = conferenceData;
    }
  }

  Event getEvent(){
    return event;
  }
   String getConferenceLink(Event value){
    return "https://meet.google.com/${value.conferenceData?.conferenceId}";
   }


  // For creating a new calendar event
  Future<Map<String, String>> insert({
    @required required String title,
    @required required String description,
    @required required String location,
    @required required List<EventAttendee> attendeeEmailList,
    @required required bool shouldNotifyAttendees,
    @required required bool hasConferenceSupport,
    @required required DateTime startTime,
    @required required DateTime endTime,
  }) async {
    late Map<String, String> eventData;

    String calendarId = "primary";


    event.summary = title;
    event.description = description;
    event.attendees = attendeeEmailList;
    event.location = location;

    if (hasConferenceSupport && event.conferenceData == null) {
      createConference(hasConferenceSupport, startTime, endTime);
    }

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+05:30";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT+05:30";
    end.dateTime = endTime;
    event.end = end;

    try {
      await calendar.events
          .insert(event, calendarId,
              conferenceDataVersion: hasConferenceSupport ? 1 : 0,
              sendUpdates: shouldNotifyAttendees ? "all" : "none")
          .then((value) {
        print("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String joiningLink = "";
          String eventId;

          eventId = value.id;

          if (hasConferenceSupport) {
            joiningLink =
                "https://meet.google.com/${value.conferenceData.conferenceId}";
          }

          eventData = {
            'id': eventId,
            'link': joiningLink,
            'location': location,
            'description': description
          };

          print('Event added to Google Calendar');
        } else {
          print("Unable to add event to Google Calendar");
        }
      });
    } catch (e) {
      print('Error creating event $e');
    }

    return eventData;
  }
}
