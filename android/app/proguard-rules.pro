# R8 rules for release builds (isMinifyEnabled = true).

# WorkManager (pulled in by the Google Mobile Ads SDK) creates its Room
# database through reflection; without these R8 removes the generated
# implementation and the app crashes at startup:
#   RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
