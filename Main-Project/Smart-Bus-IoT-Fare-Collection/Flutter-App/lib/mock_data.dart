import 'models/models.dart';

/// Real Bengaluru route matching the physical hardware's stop list and
/// DFPlayer track numbers (track = 6 + stop number, per the Arduino
/// sketch's SD card layout) — kept in sync with esp32/smart_bus_fare_gate.ino
/// so the dashboard's "Current Stop" always matches what the hardware
/// announces. x/y are normalised 0..1 coordinates for the schematic
/// live-map widget (no Google Maps API key needed).
///
/// Fare shown here (₹10 per travelled stop) is for the DISPLAY-only Route Stops
/// timeline and the prototype's local card state. Physical hardware
/// remains the source of truth for the real RFID/fare flow; Firestore
/// mirrors the card and transaction history for the Flutter dashboards.
final List<RouteStop> kRouteStops = [
  const RouteStop(
      id: 'S01',
      name: 'Kempegowda BS',
      fare: 0,
      audioTrack: '007.mp3',
      x: 0.05,
      y: 0.88,
      lat: 12.9767,
      lng: 77.5713),
  const RouteStop(
      id: 'S02',
      name: 'Maharanis Coll',
      fare: 10,
      audioTrack: '008.mp3',
      x: 0.10,
      y: 0.78,
      lat: 12.9721,
      lng: 77.5789),
  const RouteStop(
      id: 'S03',
      name: 'KR Circle',
      fare: 10,
      audioTrack: '009.mp3',
      x: 0.16,
      y: 0.79,
      lat: 12.9757,
      lng: 77.5926),
  const RouteStop(
      id: 'S04',
      name: 'St Marthas Hosp',
      fare: 10,
      audioTrack: '010.mp3',
      x: 0.21,
      y: 0.69,
      lat: 12.9698,
      lng: 77.5959),
  const RouteStop(
      id: 'S05',
      name: 'Corporation',
      fare: 10,
      audioTrack: '011.mp3',
      x: 0.26,
      y: 0.70,
      lat: 12.9634,
      lng: 77.5885),
  const RouteStop(
      id: 'S06',
      name: 'Poornima Talki',
      fare: 10,
      audioTrack: '012.mp3',
      x: 0.31,
      y: 0.60,
      lat: 12.9762,
      lng: 77.5751),
  const RouteStop(
      id: 'S07',
      name: 'Lalbagh Main G',
      fare: 10,
      audioTrack: '013.mp3',
      x: 0.37,
      y: 0.62,
      lat: 12.9507,
      lng: 77.5848),
  const RouteStop(
      id: 'S08',
      name: 'Lalbagh West G',
      fare: 10,
      audioTrack: '014.mp3',
      x: 0.42,
      y: 0.51,
      lat: 12.9542,
      lng: 77.5806),
  const RouteStop(
      id: 'S09',
      name: 'Ashoka Pillar',
      fare: 10,
      audioTrack: '015.mp3',
      x: 0.47,
      y: 0.53,
      lat: 12.9422,
      lng: 77.5806),
  const RouteStop(
      id: 'S10',
      name: 'Rani Sarala HS',
      fare: 10,
      audioTrack: '016.mp3',
      x: 0.53,
      y: 0.42,
      lat: 12.935,
      lng: 77.583),
  const RouteStop(
      id: 'S11',
      name: '3rd Blk Jayanag',
      fare: 10,
      audioTrack: '017.mp3',
      x: 0.58,
      y: 0.44,
      lat: 12.9279,
      lng: 77.583),
  const RouteStop(
      id: 'S12',
      name: '4th Blk Jayanag',
      fare: 10,
      audioTrack: '018.mp3',
      x: 0.63,
      y: 0.33,
      lat: 12.9308,
      lng: 77.5838),
  const RouteStop(
      id: 'S13',
      name: 'Jayanagar Chrch',
      fare: 10,
      audioTrack: '019.mp3',
      x: 0.69,
      y: 0.35,
      lat: 12.925,
      lng: 77.59),
  const RouteStop(
      id: 'S14',
      name: 'Sanjay Gandhi H',
      fare: 10,
      audioTrack: '020.mp3',
      x: 0.74,
      y: 0.25,
      lat: 12.928,
      lng: 77.595),
  const RouteStop(
      id: 'S15',
      name: 'Carmel Convent',
      fare: 10,
      audioTrack: '021.mp3',
      x: 0.79,
      y: 0.26,
      lat: 12.935,
      lng: 77.595),
  const RouteStop(
      id: 'S16',
      name: 'Pump House',
      fare: 10,
      audioTrack: '022.mp3',
      x: 0.84,
      y: 0.16,
      lat: 12.915,
      lng: 77.598),
  const RouteStop(
      id: 'S17',
      name: 'East End Jayang',
      fare: 10,
      audioTrack: '023.mp3',
      x: 0.90,
      y: 0.17,
      lat: 12.92,
      lng: 77.605),
  const RouteStop(
      id: 'S18',
      name: '16th Main BTM',
      fare: 10,
      audioTrack: '024.mp3',
      x: 0.95,
      y: 0.07,
      lat: 12.9165,
      lng: 77.6101),
];

List<RfidWallet> buildInitialWallets() => [
      RfidWallet(uid: '5402BBA9', holderName: 'Bhanu Prakash', balance: 10, active: true, isDemo: false),
      RfidWallet(uid: '63E6D51D', holderName: 'Karthik', balance: 200, active: true, isDemo: false),
      RfidWallet(uid: 'F0C27F5F', holderName: 'Gayathri', balance: 200, active: true, isDemo: false),
      RfidWallet(uid: '3D085006', holderName: 'Shyamala', balance: 5, active: true, isDemo: false),
      RfidWallet(uid: '21DB3E0A', holderName: 'Prema', balance: 50, active: false, isDemo: false),
      RfidWallet(uid: '5B850B1A', holderName: 'Kanthesh', balance: 200, active: true, isDemo: false),
      RfidWallet(uid: '90444455', holderName: 'Niharika', balance: 200, active: true, isDemo: false),
      RfidWallet(uid: 'A1B2C3D4', holderName: 'Rajesh Gowda', balance: 150, active: true, isDemo: false),
      RfidWallet(uid: 'B2C3D4E5', holderName: 'Sneha Rao', balance: 180, active: true, isDemo: false),
      RfidWallet(uid: 'C3D4E5F6', holderName: 'Ananya Sharma', balance: 120, active: true, isDemo: false),
      RfidWallet(uid: 'D4E5F607', holderName: 'Suresh Kumar', balance: 95, active: true, isDemo: false),
      RfidWallet(uid: 'E5F60718', holderName: 'Pooja N', balance: 220, active: true, isDemo: false),
    ];

/// Initial passenger transaction history starts empty so that only REAL
/// hardware taps from RFID / NodeMCU populate the history.
List<FareTransaction> buildPrototypeTransactions() {
  return <FareTransaction>[];
}
