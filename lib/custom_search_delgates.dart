import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef OnSearchChanged = Future<List<String>> Function(String);

class SearchWithSuggestionDelegate extends SearchDelegate<String> {
  ///[onSearchChanged] gets the [query] as an argument. Then this callback
  ///should process [query] then return an [List<String>] as suggestions.
  ///Since its returns a [Future] you get suggestions from server too.
  final OnSearchChanged onSearchChanged;
  List<String> homeimgs;

  ///This [_oldFilters] used to store the previous suggestions. While waiting
  ///for [onSearchChanged] to completed, [_oldFilters] are displayed.
  List<String> _oldFilters = const [];
  ///List<String> _searchList;

  SearchWithSuggestionDelegate({String searchFieldLabel, this.onSearchChanged})
      : super(searchFieldLabel: searchFieldLabel);

  ///
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = "",
      ),
    ];
  }

  ///OnSubmit in the keyboard, returns the [query]
  @override
  void showResults(BuildContext context) {
    close(context, query);
  }

  ///Since [showResults] is overridden we can don't have to build the results.
  @override
  Widget buildResults(BuildContext context) => null;

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: onSearchChanged != null ? onSearchChanged(query) : null,
      builder: (context, snapshot) {
        if (snapshot.hasData) _oldFilters = snapshot.data;
        return ListView.builder(
          itemCount: _oldFilters.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.restore),
              title: Text("${_oldFilters[index]}"),
              onTap: () => close(context, _oldFilters[index]),
              trailing: IconButton(
                icon: Icon(Icons.clear),
                onPressed: (){
                  return showDialog(context: context,builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Remove from search history!',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                      content: Text('Are you sure you want to remove "${_oldFilters[index]}" from search history?'),
                      actions: <Widget>[
                        FlatButton(child: Text("CANCEL"),onPressed: (){Navigator.pop(context);},),
                        FlatButton(child: Text("REMOVE"),onPressed: ()async{
                          final pref = await SharedPreferences.getInstance();
                          List<String> recentList=pref.getStringList("recentSearches");
                          final isRemoved=recentList.remove(_oldFilters[index]);
                          pref.setStringList("recentSearches", recentList.toList());
                          if(isRemoved==true){
                            Navigator.pop(context);
                          }
                        },),
                      ]
                );});}
              ),
            );
          },
        );
      },
    );
  }
}