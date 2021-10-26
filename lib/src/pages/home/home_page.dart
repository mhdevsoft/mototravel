import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:mototravel/src/pages/home/home_controller.dart';
//diseños y no elementos que cambien

class HomePage extends StatelessWidget {
  //declaramos nuestra clase con construcctor de manera global
   homecontroller _con = new homecontroller();
  @override
  Widget build(BuildContext context)
   {
       _con.init(context); //inicializamos el metodo 
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
              _textShow('Selecciona Tu Rol'),
              SizedBox(height: 50),
              //Circle Avatar para poner una imagen redonda
               _avatarCircle(context , 'assets/img/user.png'),
              SizedBox(height: 10,),
              _textShow('cliente'),
              SizedBox(height: 25),
              _images(context, 'assets/img/driver.png'),
              SizedBox(height: 10,),
               _textShow('conductor'),
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


//agregamos el build context y el context de home page
  Widget _avatarCircle(BuildContext context, String url)
  {
    return
    //Gesture Dectector para capturar la accion que hara el cliente
    GestureDetector(
      //on tap cuando haga clic que accion realizara
        onTap: _con.goToLogin,
      child: CircleAvatar(
                  backgroundImage: AssetImage(url),
                  //Tamaño de la imagen
                  radius: 50,
                  //Color Predeterminado
                  backgroundColor: Colors.transparent
                ),
    );
  }


  Widget _images(BuildContext context , String location)
  {
     return GestureDetector(
       onTap: _con.goToLogin,
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
