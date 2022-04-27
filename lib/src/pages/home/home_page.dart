import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mototravel/src/pages/home/home_controller.dart';
//diseños y no elementos que cambien

class HomePage extends StatefulWidget {
  //declaramos nuestra clase con construcctor de manera global
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   homecontroller _con = new homecontroller();

 @override
 //nunca afectara al contruir el diseño
  void initState() {
    super.initState();
    //ejecutara despues del la costruccion del diseño
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });

  }

  @override
  Widget build(BuildContext context)
   {
  
    // etiqueta del esqueleto de la pantalla
    return Scaffold(
      //propiedades

      body: SafeArea(
        child: Container(
            decoration: BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topRight,
               end: Alignment.bottomLeft,
               colors: [Colors.purple,Colors.blue]
             )

            ),
          child: Column(
            children: [
              
             _clipshow(context),  
            //Con SizedBox Dejamos el espacio hacia abajo
              SizedBox(height: 50,),
              _textShow('¿Que Usuario Eres?'),
              SizedBox(height: 50),
              //Circle Avatar para poner una imagen redonda
               _avatarCircle(context , 'assets/img/user.png','client'),
              SizedBox(height: 10,),
              _textShow('Soy cliente'),
              SizedBox(height: 25),
              _images(context, 'assets/img/driver.png','driver'),
              SizedBox(height: 10,),
               _textShow('Soy conductor'),
              SizedBox(height: 21),
               
            ],
            
          ),
          
        ),
      ),
    );
  }

  Widget _textShow(String letra)
  {
    return Text(letra,
            style: TextStyle (color: Colors.white)
    );
  }

  Widget _avatarCircle(BuildContext context, String url , String typeUser)
  {
    return
    //Gesture Dectector para capturar la accion que hara el cliente
    GestureDetector(
      //on tap cuando haga clic que accion realizara
        onTap:() =>_con.goToLogin(typeUser) //ejecutar eventos con parametros
        ,
      child: CircleAvatar(
                  backgroundImage: AssetImage(url),
                  //Tamaño de la imagen
                  radius: 50,
                  //Color Predeterminado
                  backgroundColor: Colors.transparent
                ),
    );
  }

  Widget _images(BuildContext context , String location, String typeUser)
  {
     return GestureDetector(
       onTap:() =>_con.goToLogin(typeUser),
       child: Image.asset(
                        location,
                         width: 150,
                         height: 110,
                        ),
     );
  }

  Widget _clipshow(BuildContext context)
  {
       return
           ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child:   Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.28,
                    child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Image.asset(
                      'assets/img/logo.png',
                       width: 200,
                       height: 180,
                      ),
                  
                ],
              ),
                  ),
                );
  }
}
