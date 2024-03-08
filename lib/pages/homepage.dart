import 'package:flutter/material.dart';
import 'package:expense_manager/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Expense Manager',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final supabase = Supabase.instance.client;
final curruser = supabase.auth.currentUser?.email;

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client
      .from('expense_manager')
      .select()
      .eq('user', curruser.toString());

  // List<Contact>? _contacts;
  // bool _permissionDenied = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchContacts();
  // }

  // Future _fetchContacts() async {
  //   if (!await FlutterContacts.requestPermission(readonly: true)) {
  //     setState(() => _permissionDenied = true);
  //   } else {
  //     final contacts = await FlutterContacts.getContacts();
  //     setState(() => _contacts = contacts);
  //   }
  // }

  // Widget _pickContact() {
  //   if (_permissionDenied) return Center(child: Text('Permission denied'));
  //   if (_contacts == null) return Center(child: CircularProgressIndicator());
  //   return ListView.builder(
  //       itemCount: _contacts!.length,
  //       itemBuilder: (context, i) => ListTile(
  //           title: Text(_contacts![i].displayName),
  //           onTap: () async {
  //             final fullContact =
  //                 await FlutterContacts.getContact(_contacts![i].id);
  //             Navigator.of(context).pop();
  //           }));
  // }
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  void addRecord() async {
    return showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Add Record'),
              content: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Enter name'),
                  ),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(hintText: 'Enter amount'),
                  ),
                  TextField(
                    controller: _mobileController,
                    decoration:
                        const InputDecoration(hintText: 'Enter mobile no'),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    int amt = int.parse(_amountController.text);
                    try {
                      await supabase.from('expense_manager').insert({
                        'name': _nameController.text,
                        'amount': amt,
                        'mobileno': _mobileController.text,
                        'user': curruser.toString(),
                      });
                      Navigator.of(context).pop();
                      setState(() {
                        _future;
                      });
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: e.toString(),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.045,
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              color: Color.fromARGB(110, 255, 143, 143),
              child: const Center(
                child: Text(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    "  -ve amount denotes amount to give\n  +ve amount denotes amount to take\n"),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tables = snapshot.data!;
                return ListView.builder(
                  itemCount: tables.length,
                  itemBuilder: ((context, index) {
                    final table = tables[index];
                    final TextEditingController editamountcontroller =
                        TextEditingController();

                    void sendMessage() async {
                      final Uri url =
                          Uri.parse('https://wa.me/${table['mobileno']}');

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    }

                    void editAmount() async {
                      return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Edit Amount'),
                              content: TextField(
                                // onChanged: (value) {
                                //   table['amount'] = value;
                                // },
                                controller: editamountcontroller,
                                decoration: const InputDecoration(
                                    hintText: 'Enter new amount'),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await supabase
                                        .from('expense_manager')
                                        .update({
                                      'amount': editamountcontroller.text
                                    }).eq('id', table['id']);

                                    Navigator.of(context).pop();
                                    setState(() {
                                      table['amount'] =
                                          editamountcontroller.text;
                                    });
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          });
                    }

                    return Card(
                      child: ListTile(
                        trailing: IconButton(
                            onPressed: sendMessage,
                            icon: const Icon(Icons.message)),
                        leading: IconButton(
                            onPressed: editAmount,
                            icon: const Icon(Icons.edit)),
                        title: Text(table['name'].toString()),
                        subtitle: Text('Rs.${table['amount'].toString()}'),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}
