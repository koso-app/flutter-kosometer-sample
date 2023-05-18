package com.koso.kosometer.ble

class AncsEventId {
    companion object {
        val EventIDNotificationAdded = 0
        val EventIDNotificationModified = 1
        val EventIDNotificationRemoved = 2
    }
}

class AncsEventFlags {
    companion object{
        val EventFlagSilent = 0x01
        val EventFlagImportant = 0x10
        val EventFlagPreExisting = 0x0100
        val EventFlagPositiveAction = 0x1000
        val EventFlagNegativeAction = 0x010000
    }
}

class AncsCategoryID {
    companion object{
        val CategoryIDOther = 0
        val CategoryIDIncomingCall = 1
        val CategoryIDMissedCall = 2
        val CategoryIDVoicemail = 3
        val CategoryIDSocial = 4
        val CategoryIDSchedule = 5
        val CategoryIDEmail = 6
        val CategoryIDNews = 7
        val CategoryIDHealthAndFitness = 8
        val CategoryIDBusinessAndFinance = 9
        val CategoryIDLocation = 10
        val CategoryIDEntertainment = 11

    }
}