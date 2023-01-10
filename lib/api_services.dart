import 'dart:convert';

import 'package:http/http.dart' as http;
String apiKey = "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";
class ApiServices{

    static String baseUrl = "https://api.openai.com/v1/completions";
    static Map<String, String> header =  {
     'Content-Type': "application/json",
     'Authorization': "Bearer $apiKey",

   };

   static sendMessage( String? message) async{
    var res =  await http.post(Uri.parse(baseUrl),
    headers: header ,
    body: jsonEncode({
      "model": "text-davinci-003",
      "prompt": "$message",
      "temperature": 0,
      "max_tokens": 100,
      "top_p": 1,
      "frequency_penalty":0.0,
      "presence_penalty": 0.0 ,
      "stop": [" Human:","AI"]

    })
    );


    if(res.statusCode == 200){
      var data = jsonDecode(res.body.toString());
      var msg =  data['choices'][0]['text'];
    return msg ;
    }
    else {
      print('failed to fetch data');
    }
  }
}