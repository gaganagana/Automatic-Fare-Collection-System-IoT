/// Prototype identity/card mapping supplied for the Smart Bus project.
/// These are configuration values only; Firebase Authentication still
/// owns passwords and generates the real Firebase Auth UIDs.
class SmartBusSeedCard {
  final String uid;
  final String holderName;
  final String email;
  final bool lowBalance;
  const SmartBusSeedCard({
    required this.uid,
    required this.holderName,
    required this.email,
    this.lowBalance = false,
  });
}

const smartBusSeedCards = <SmartBusSeedCard>[
  SmartBusSeedCard(uid: '63E6D51D', holderName: 'Karthik', email: 'gaganagana0822@gmail.com'),
  SmartBusSeedCard(uid: 'F0C27F5F', holderName: 'Gayathri', email: 'gaganacp2002@gmail.com'),
  SmartBusSeedCard(uid: '90444455', holderName: 'Nharika', email: 'niharikarm123@gmail.com'),
  SmartBusSeedCard(uid: '5402BBA9', holderName: 'Bhanu Prakash', email: 'crazysky2201@gmail.com'),
  SmartBusSeedCard(uid: '5B850B1A', holderName: 'Kanthesh', email: 'pp761254@gmail.com'),
  SmartBusSeedCard(uid: '3D085006', holderName: 'Shyamala', email: 'skycrazy803@gmail.com', lowBalance: true),
  SmartBusSeedCard(uid: '21DB3E0A', holderName: 'Prema', email: 'gaganaprema22@gmail.com', lowBalance: true),
];

const smartBusAdminName = 'Gagana';
const smartBusAdminEmail = 'gaganacp2002@gmail.com';
