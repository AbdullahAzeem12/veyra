import '../models/stay.dart';
import '../models/search_criteria.dart';
import '../models/booking.dart';

/// Abstract interface for stay data operations.
abstract class StayRepository {
  Stream<List<Stay>> streamFeaturedStays();
  Stream<List<Stay>> searchStays(SearchCriteria criteria);
  Stream<Stay?> streamStayById(String stayId);
  Stream<List<Stay>> streamDestinationStays(String destinationId);
  Future<void> dispose();
}

/// Abstract interface for saved-stays (favourites).
abstract class SavedRepository {
  Stream<Set<String>> streamSavedStayIds(String userId);
  Future<void> toggleSavedStay({required String userId, required String stayId});
  Future<void> dispose();
}

/// Abstract interface for booking operations.
abstract class BookingRepository {
  Stream<List<Booking>> streamBookings(String userId);
  Future<String> createBooking(BookingDraft draft);
  Future<void> cancelBooking(String bookingId);
  Future<void> dispose();
}
