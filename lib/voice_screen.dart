import 'package:chatgpt_voice/api_services.dart';
import 'package:chatgpt_voice/chat_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {

  SpeechToText speechToText = SpeechToText();
  var isListening = false;
  var text = "Hold to search anything ";

  final List<ChatMessage> messages =[];
  var scrollController =  ScrollController();

  scrollMethod(){
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 80.0,
        animate: isListening,
        duration: Duration(milliseconds: 2000),
        glowColor: Colors.purple,
        repeat: true,
        repeatPauseDuration: Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details)async{
            if(!isListening){
              var available = await speechToText.initialize();
              if(available){
                setState(() {
                  isListening = true;
                  speechToText.listen(
                    onResult: (result){
                      setState(() {
                        text = result.recognizedWords;
                      });
                    }
                  );
                });
              }
            }
          },
          onTapUp: (details) async{
            setState(() {
              isListening = false;
            });
            speechToText.stop();

            messages.add(ChatMessage(text: text, type: ChatMessageType.user));
            var msg = await ApiServices.sendMessage(text);
            setState(() {
              messages.add(ChatMessage(text: msg, type: ChatMessageType.bot));
            });
          },
          child: CircleAvatar(
            backgroundColor: Colors.purple,
            radius: 40,
            child: isListening ? Icon(Icons.mic) : Icon(Icons.mic_none),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        leading: Icon(Icons.mic),
        centerTitle: true,
        title: Text("ChatGPT Voice"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24 ,vertical: 16),

        child: Column(
          children: [
            Text(text, style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isListening ? Colors.black87 :Colors.black54
            ),),
            const SizedBox(height: 12,),
            Expanded(child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15)
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context , int index){
                  var chat = messages[index];

                    return chatBubble(
                      chattext: chat.text
                          ,
                      type: chat.type
                    );
                  }
              ),
              
            )),
            const SizedBox(height: 12,),
            Text('Developed by utkarsh', style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isListening ? Colors.black87 :Colors.black54
            ),),
          ],
        ),
      ),
    );
  }



  Widget chatBubble ( { required chattext , required ChatMessageType?  type}){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        CircleAvatar(
          backgroundColor: Colors.purple,
          child: type == ChatMessageType.bot ? Image.asset('assets/openai.png') :Icon(Icons.person,color: Colors.white,),
        ),
        SizedBox(width: 12,),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: type == ChatMessageType.bot ? Colors.purple :Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),

              )
            ),
            child: Text(
              chattext,
              style: TextStyle(
                color: type == ChatMessageType.bot ? Colors.white :Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
        ),
      ],
    );
  }
}
