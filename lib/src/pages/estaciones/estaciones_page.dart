import 'package:app_plaga_enfermedades/src/bloc/fincas_bloc.dart';
import 'package:app_plaga_enfermedades/src/models/decisiones_model.dart';
import 'package:app_plaga_enfermedades/src/models/finca_model.dart';
import 'package:app_plaga_enfermedades/src/models/parcela_model.dart';
import 'package:app_plaga_enfermedades/src/models/planta_model.dart';
import 'package:app_plaga_enfermedades/src/models/testplaga_model.dart';
import 'package:app_plaga_enfermedades/src/providers/db_provider.dart';
import 'package:app_plaga_enfermedades/src/utils/constants.dart';
import 'package:app_plaga_enfermedades/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EstacionesPage extends StatefulWidget {
    const EstacionesPage({Key key}) : super(key: key);

  @override
  _EstacionesPageState createState() => _EstacionesPageState();
}

class _EstacionesPageState extends State<EstacionesPage> {

    final fincasBloc = new FincasBloc();

    Future _getdataFinca(Testplaga textPlaga) async{
        Finca finca = await DBProvider.db.getFincaId(textPlaga.idFinca);
        Parcela parcela = await DBProvider.db.getParcelaId(textPlaga.idLote);
        List<Decisiones> desiciones = await DBProvider.db.getDecisionesIdTest(textPlaga.id);
        
        return [finca, parcela, desiciones];
    }

    @override
    Widget build(BuildContext context) {
        
        Testplaga plaga = ModalRoute.of(context).settings.arguments;
        fincasBloc.obtenerPlantas(plaga.id);
        

       return StreamBuilder<List<Planta>>(
            stream: fincasBloc.countPlanta,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                List<Planta> plantas= snapshot.data;
                //print(plantas.length);
                fincasBloc.obtenerDecisiones(plaga.id);
                int estacion1 = 0;
                int estacion2 = 0;
                int estacion3 = 0;
                List countEstaciones = [];

                for (var item in plantas) {
                    if (item.estacion == 1) {
                        estacion1 ++;
                    } else if (item.estacion == 2){
                        estacion2 ++;
                    }else{
                        estacion3 ++;
                    }
                }
                countEstaciones = [estacion1,estacion2,estacion3];
                
                return Scaffold(
                    appBar: AppBar(),
                    body: Column(
                        children: [
                            escabezadoEstacion( context, plaga ),
                            InkWell(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        TitulosPages(titulo: 'Estaciones'),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10, top: 5),
                                            child: Icon(
                                                Icons.info_outline_rounded,
                                                color: Colors.green,
                                                size: 25.0,
                                            ),
                                        ),
                                    ],
                                ),
                                onTap: () => _dialogText(context),
                            ),
                            
                            Divider(),
                            Expanded(
                                child: SingleChildScrollView(
                                    child: _listaDeEstaciones( context, plaga, countEstaciones ),
                                ),
                            ),
                        ],
                    ),
                    bottomNavigationBar: BottomAppBar(
                        child: _tomarDecisiones(countEstaciones, plaga)
                    ),
                );
            },
        );
    }



    Widget escabezadoEstacion( BuildContext context, Testplaga plaga ){


        return FutureBuilder(
            future: _getdataFinca(plaga),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                }
                Finca finca = snapshot.data[0];
                Parcela parcela = snapshot.data[1];

                return Container(
                    
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                            BoxShadow(
                                    color: Color(0xFF3A5160)
                                        .withOpacity(0.05),
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 17.0),
                            ],
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            
                            Flexible(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                    
                                        Padding(
                                            padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                            child: Text(
                                                "${finca.nombreFinca}",
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: Theme.of(context).textTheme.headline6,
                                            ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only( bottom: 10.0),
                                            child: Text(
                                                "${parcela.nombreLote}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: kLightBlackColor),
                                            ),
                                        ),
                                        
                                    ],  
                                ),
                            ),
                        ],
                    ),
                );
            },
        );        
    }

    Widget  _listaDeEstaciones( BuildContext context, Testplaga plaga, List countEstaciones){
        return ListView.builder(
            itemBuilder: (context, index) {
                String estadoConteo;
                if (countEstaciones[index] >= 10){
                    estadoConteo =  'Completo';
                }else{
                   estadoConteo =  'Incompleto'; 
                }
                return GestureDetector(
                    
                    child: _cardTest(index+1,countEstaciones[index], estadoConteo),
                    onTap: () => Navigator.pushNamed(context, 'plantas', arguments: [plaga, index]),
                );
                
               
            },
            shrinkWrap: true,
            itemCount:  plaga.estaciones,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardTest(int estacion, int numeroPlantas, String estado){
        return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        
                        Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                
                                    Padding(
                                        padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                        child: Text(
                                            "Estación $estacion",
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline6,
                                        ),
                                    ),
                                    
                                    
                                    Padding(
                                        padding: EdgeInsets.only( bottom: 10.0),
                                        child: Text(
                                            '$estado',
                                            style: TextStyle(color: kLightBlackColor),
                                        ),
                                    ),
                                ],  
                            ),
                        ),
                        Container(
                            child: CircularPercentIndicator(
                                radius: 70.0,
                                lineWidth: 5.0,
                                animation: true,
                                percent: numeroPlantas/10,
                                center: new Text("${(numeroPlantas/10)*100}%"),
                                progressColor: Color(0xFF498C37),
                            ),
                        )
                        
                        
                        
                    ],
                ),
        );
    }
   

    Widget  _tomarDecisiones(List countEstaciones, Testplaga plaga){
        
        if(countEstaciones[0] >= 10 && countEstaciones[1] >= 10 && countEstaciones[2] >= 10){
            
            return StreamBuilder(
            stream: fincasBloc.decisionesStream ,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                    }
                    List<Decisiones> desiciones = snapshot.data;

                    //print(desiciones);

                    if (desiciones.length == 0){

                        return Container(
                            color: kBackgroundColor,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                                child: RaisedButton.icon(
                                    icon:Icon(Icons.add_circle_outline_outlined),
                                    
                                    label: Text('Toma de decisiones',
                                        style: Theme.of(context).textTheme
                                            .headline6
                                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
                                    ),
                                    padding:EdgeInsets.all(13),
                                    onPressed: () => Navigator.pushNamed(context, 'decisiones', arguments: plaga),
                                )
                            ),
                        );
                        
                    }


                    return Container(
                        color: kBackgroundColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                            child: RaisedButton.icon(
                                icon:Icon(Icons.receipt_rounded),
                            
                                label: Text('Consultar decisiones',
                                    style: Theme.of(context).textTheme
                                        .headline6
                                        .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
                                ),
                                padding:EdgeInsets.all(13),
                                onPressed: () => Navigator.pushNamed(context, 'reporte', arguments: plaga.id),
                            )
                        ),
                    );
                                       
                },  
            );
        }
        

        return Container(
            color: kBackgroundColor,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                    "Complete las estaciones",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme
                        .headline5
                        .copyWith(fontWeight: FontWeight.w900, color: kRedColor, fontSize: 22)
                ),
            ),
        );
    }
}

Future<void> _dialogText(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Titulo'),
                content: SingleChildScrollView(
                    child: ListBody(
                        children: <Widget>[
                        Text('Texto para breve explicacion'),
                        ],
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                    ),
                ],
            );
        },
    );
}