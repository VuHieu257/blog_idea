//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../models/b_idea.dart';
// import '../../service/database/database_service.dart';
//
// class DetailHikePage extends StatefulWidget {
//   String id;
//   String name;
//   String description;
//   String locationOfHike;
//   int levelOfHike;
//   int lengthOfHike;
//   Timestamp date;
//   bool parkingAvailable;
//   String createdAccount;
//
//   // Khởi tạo trang detail với dữ liệu được truyền từ trang home
//   DetailHikePage({super.key,required this.id, required this.name, required this.description,required this.locationOfHike, required this.levelOfHike, required this.lengthOfHike,required this.date, required this.parkingAvailable,required this.createdAccount});
//
//   @override
//   State<DetailHikePage> createState() => _DetailHikePageState();
// }
//
// class _DetailHikePageState extends State<DetailHikePage> {
//   TextEditingController textEditingControllerName=TextEditingController();
//   final TextEditingController textEditingControllerLocation=TextEditingController();
//   final TextEditingController textEditingControllerDate=TextEditingController();
//   final TextEditingController textEditingControllerParkingAvailable=TextEditingController();
//   final TextEditingController textEditingControllerLength=TextEditingController();
//   final TextEditingController textEditingControllerLevel=TextEditingController();
//   final TextEditingController textEditingControllerDescription=TextEditingController();
//
//   //check status update
//   bool updateSuccess = false;
//
//   final int levelOfHike=1;
//   int _selectedValue = 1;
//   bool _selectedValueParkingAvailable = true;
//
//   DateTime selectedDate = DateTime.now();
//   late Timestamp timestamp;
//
//   _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2025),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         // selectedDate = picked;
//         timestamp = Timestamp.fromDate(picked);
//       });
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.levelOfHike;
//     _selectedValueParkingAvailable = widget.parkingAvailable;
//     timestamp=widget.date;
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final TextEditingController textEditingControllerName=TextEditingController(text: widget.name);
//     final DatabaseService _databaseService=DatabaseService();
//     double width=MediaQuery.of(context).size.width;
//     double height=MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         leading: InkWell(onTap: () => Navigator.pop(context),child: const Icon(Icons.arrow_back,color: Colors.white,),),
//         title: const Center(child: Text("M-Hike",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),)),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               customTextField(width,Icons.account_circle_outlined,"Name",widget.name,textEditingControllerName,false),
//               Container(height: 1,color: Colors.grey,),
//
//               customTextField(width,Icons.pin_drop_outlined,"Location",widget.locationOfHike,textEditingControllerLocation,false),
//               Container(height: 1,color: Colors.grey,),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.date_range),
//                     const SizedBox(width: 10,),
//                     const Text("Date",  style: TextStyle(fontSize: 18),),
//                     const Spacer(),
//                     ElevatedButton(onPressed: () {_selectDate(context);}, child: Text(DateFormat("MM-dd-yyyy h:mm a").format(timestamp.toDate()),style: const TextStyle(fontSize: 18,color: Colors.blue),)),
//                   ],
//                 ),
//               ),
//               // customTextField(width,Icons.date_range,"Date",DateFormat("MM-dd-yyyy h:mm a").format(widget.date.toDate()),textEditingControllerDate,false),
//               Container(height: 1,color: Colors.grey,),
//
//               // customTextField(width,Icons.push_pin_outlined,"Parking Available",widget.parkingAvailable?"Yes":"No",textEditingControllerParkingAvailable,false),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.push_pin_outlined),
//                     const SizedBox(width: 10,),
//                     const Text("Parking Available",  style: TextStyle(fontSize: 18),),
//                     const Spacer(),
//                     Container(
//                       decoration: BoxDecoration(
//                         // color: Colors.blue.shade50,
//                           borderRadius: const BorderRadius.all(Radius.circular(10)),
//                           border: Border.all(width: 1,color: Colors.blue)
//                       ),
//                       padding: const EdgeInsets.all(5),
//                       child: DropdownButton<bool>(
//                         iconEnabledColor: Colors.blue,
//                         borderRadius: const BorderRadius.all(Radius.circular(10)),
//                         value:_selectedValueParkingAvailable,
//                         onChanged: (bool? newValue) {
//                           setState(() {
//                             _selectedValueParkingAvailable = newValue!;
//                             print(_selectedValueParkingAvailable);
//                           });
//
//                         },
//                         underline: Container(),
//                         items: const [
//                           DropdownMenuItem<bool>(
//                             value: true,
//                             child: Text('Yes'),
//                           ),
//                           DropdownMenuItem<bool>(
//                             value: false,
//                             child: Text('No'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(height: 1,color: Colors.grey,),
//               customTextField(width,Icons.legend_toggle,"Length","${widget.lengthOfHike}",textEditingControllerLength,false),
//               // customTextField(width,Icons.leaderboard_outlined,"Level",widget.levelOfHike==1?"Easy":(widget.levelOfHike==2?"Normal":"Hard"),textEditingControllerLevel,false),
//               Container(height: 1,color: Colors.grey,),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.leaderboard_outlined),
//                     const SizedBox(width: 10,),
//                     const Text("Level",  style: TextStyle(fontSize: 18),),
//                     const Spacer(),
//                     Container(
//                       decoration: BoxDecoration(
//                           borderRadius: const BorderRadius.all(Radius.circular(10)),
//                           border: Border.all(width: 1,color: Colors.blue)
//                       ),
//                       padding: const EdgeInsets.all(5),
//                       child: DropdownButton<int>(
//                         iconEnabledColor: Colors.blue,
//                         borderRadius: const BorderRadius.all(Radius.circular(10)),
//                         value: _selectedValue,
//                         onChanged: (int? newValue) {
//                           setState(() {
//                             _selectedValue = newValue!;
//                             print(_selectedValue);
//                           });
//                         },
//                         underline: Container(),
//                         items: const [
//                           DropdownMenuItem<int>(
//                             value: 1,
//                             child: Text('Easy'),
//                           ),
//                           DropdownMenuItem<int>(
//                             value: 2,
//                             child: Text('Normal'),
//                           ),
//                           DropdownMenuItem<int>(
//                             value: 3,
//                             child: Text('Hard'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(height: 1,color: Colors.grey,),
//               customTextField(width,Icons.note_outlined,"Description",widget.description,textEditingControllerDescription,false),
//               // const DropdownExample(),
//               Container(height: 1,color: Colors.grey,),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Row(
//         children: [
//           const Spacer(),
//           InkWell(
//             onTap: () async {
//               Todo updatedTodo = Todo(
//                 idUser: "a",
//                 name: textEditingControllerName.text.isNotEmpty ? textEditingControllerName.text : widget.name,
//                 description: textEditingControllerDescription.text.isNotEmpty ? textEditingControllerDescription.text : widget.description,
//                 locationOfHike: textEditingControllerLocation.text.isNotEmpty ? textEditingControllerLocation.text : widget.locationOfHike,
//                 levelOfHike: _selectedValue,
//                 lengthOfHike: textEditingControllerLength.text.isNotEmpty ? int.tryParse(textEditingControllerLength.text) ?? widget.lengthOfHike : widget.lengthOfHike,
//                 date: timestamp,
//                 parkingAvailable: _selectedValueParkingAvailable,
//                 createdAccount: widget.createdAccount, imgPost: '',
//               );
//               // print(textEditingControllerName.text);
//               //   _databaseService.updateTodo(widgetId, updatedTodo);
//               try {
//                 await _databaseService.updateTodo(widget.id, updatedTodo);
//                 Navigator.pop(context);
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                     content: Text('Update success'),
//                   ));
//                 });
//                 updateSuccess = true;
//               } catch (error) {
//                 print('Error updating todo: $error');
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Update failed. Please try again.'),
//                 ));
//               }
//             },
//             splashColor: Colors.transparent,
//             // onTap: callback,
//             child: Container(
//               height:height*0.06,
//               width: width*0.3,
//               margin: const EdgeInsets.symmetric(vertical: 15,horizontal: 35),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF00B6F0),
//                 borderRadius: const BorderRadius.all(
//                   Radius.circular(16.0),
//                 ),
//                 boxShadow: <BoxShadow>[
//                   BoxShadow(
//                       color: const Color(0xFF00B6F0)
//                           .withOpacity(0.5),
//                       offset: const Offset(1.1, 1.1),
//                       blurRadius: 10.0),
//                 ],
//               ),
//               child: const Center(
//                 child: Text(
//                   'Update',
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                     letterSpacing: 0.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           InkWell(
//             splashColor: Colors.transparent,
//             onTap:() async {
//               try {
//                 await _databaseService.deleteTodo(widget.id);
//                 Navigator.pop(context);
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                     content: Text('Delete success'),
//                   ));
//                 });
//                 updateSuccess = true;
//               } catch (error) {
//                 print('Error updating todo: $error');
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Delete failed. Please try again.'),
//                 ));
//               }
//             },
//             child: Container(
//               height:height*0.06,
//               width: width*0.3,
//               margin: const EdgeInsets.symmetric(vertical: 15,horizontal: 35),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF00B6F0),
//                 borderRadius: const BorderRadius.all(
//                   Radius.circular(16.0),
//                 ),
//                 boxShadow: <BoxShadow>[
//                   BoxShadow(
//                       color: const Color(0xFF00B6F0)
//                           .withOpacity(0.5),
//                       offset: const Offset(1.1, 1.1),
//                       blurRadius: 10.0),
//                 ],
//               ),
//               child: const Center(
//                 child: Text(
//                   'Delete',
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                     letterSpacing: 0.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//
//         ],
//       ),
//     );
//   }
//   Padding customTextField(double width,IconData icon,String title,String value,TextEditingController _controller, bool status){
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon),
//           const SizedBox(width: 10,),
//           status?
//           Text.rich(
//               TextSpan(text: title,
//                   style: const TextStyle(fontSize: 18),
//                   children: const [
//                     TextSpan(text: " *",style: TextStyle(color: Colors.red))
//                   ]
//               )
//           ):Text(title,  style: const TextStyle(fontSize: 18),),
//           const Spacer(),
//           SizedBox(
//             width: width*0.5,
//             child: TextField(
//               style: const TextStyle(color: Colors.blue,fontSize: 18),
//               controller: _controller,
//               readOnly: false,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: value==""?"Enter $title":value,
//                   hintStyle: const TextStyle(color: Colors.blue)
//               ),),
//           )
//         ],
//       ),
//     );
//   }
// }