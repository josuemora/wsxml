//
//  ViewController.m
//  wsxml
//
//  Created by Joshua on 28/08/14.
//  Copyright (c) 2014 Joshua. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSXMLParser *xmlLector;
    NSMutableString *currentElementValue;
    
    //NSMutableDictionary *aUsuariosAux;
    NSString *statusConsulta;
    //NSString * mensajeAux;
    NSMutableDictionary * xmlNivel1;
    NSMutableDictionary * xmlNivel2;
    NSMutableArray *aAux;
    NSString * nivel1;
    NSString * nivel2;
    
    
}


@end

@implementation ViewController
@synthesize txt_finales,txt_raw,campo_correo,campo_nombre;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_buscar:(id)sender {
    
    /* Primera Parte. Obtener datos */
    
    //Definicion de variables del WS
    NSString *stringURL = @"http://10.1.10.80:8080/wsa/wsa1";
    NSString *stringVars = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:wsom=\"http://xbol/wsomniticket_qa\"><soapenv:Header/><soapenv:Body><wsom:mnto_ClientesMstr><wsom:xmlINPUT><![CDATA[<root><Tipo_id>C</Tipo_id><Cliente_id>%@</Cliente_id><Nombre>%@</Nombre><Apellidos></Apellidos><Pais></Pais><Estado_id></Estado_id><Ciudad_id></Ciudad_id><Cp></Cp><Direccion></Direccion><Telefono></Telefono><Celular></Celular><Tarjeta></Tarjeta><Password></Password><Genero></Genero><Fecha_nac></Fecha_nac><Edad></Edad><Banco></Banco><Activo></Activo><URL1></URL1><URL2></URL2><URL3></URL3><IMAGEN_1></IMAGEN_1><IMAGEN_2></IMAGEN_2><IMAGEN_3></IMAGEN_3><Palabra_Com></Palabra_Com><Pos_ini></Pos_ini><Pos_fin></Pos_fin><Cuantos></Cuantos></root>]]></wsom:xmlINPUT></wsom:mnto_ClientesMstr></soapenv:Body></soapenv:Envelope>";
    
    //validacion de captura.
    if ([campo_correo.text isEqualToString:@""]) {
        campo_correo.text = @"captura correo o parte del correo";
    }
    if ([campo_nombre.text isEqualToString:@""]) {
        campo_nombre.text = @"captura nombre o parte del nombre";
    }
    stringVars = [NSString stringWithFormat:stringVars,campo_correo.text,campo_nombre.text];
    NSLog(@"cadena de envio %@\n\n",stringVars);
    
    //Definicion de variables para coneccion.
    NSString* varLen = [NSString stringWithFormat:@"%lu",(unsigned long)[stringVars length]];
    NSURL* tmpURL = [[NSURL alloc] initWithString:stringURL ] ;
    NSMutableURLRequest* peticion = [NSMutableURLRequest requestWithURL:tmpURL];
    [peticion setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [peticion setValue:@"http://schemas.xmlsoap.org/wsdl/soap/" forHTTPHeaderField:@"SOAPAction"];
    [peticion setValue:varLen forHTTPHeaderField:@"Content-Length"];
    [peticion setHTTPMethod:@"POST"];
    [peticion setHTTPBody:[stringVars dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Ejecucion de la peticion
    NSData  *tmpData  = [NSURLConnection sendSynchronousRequest:peticion returningResponse:NULL error:NULL];
    NSString *tmpResp = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
    //NSLog(@"RESPUESTA WS: \n\n%@\n\n",tmpResp);
    txt_raw.text = [[NSString alloc] initWithFormat:@"RESPUESTA WS: \n\n%@\n\n",tmpResp ];
    
    //Depuracion y presentacion de datos
    tmpResp = [self textToHtml:tmpResp];
    NSArray *aCadenas = [tmpResp componentsSeparatedByString:@"<xmlOUTPUT>"];
    if([aCadenas count] > 1){
        aCadenas = [[aCadenas objectAtIndex:1] componentsSeparatedByString:@"</xmlOUTPUT>"];
    }
    NSString * xmlOUTPUT = [aCadenas objectAtIndex:0];
    //NSLog(@"Respuesta xmlOUTPUT: \n\n%@\n\n", xmlOUTPUT);
    txt_raw.text = [[NSString alloc] initWithFormat:@"%@\n\nRespuesta xmlOUTPUT: \n\n%@",txt_raw.text,xmlOUTPUT ];
    txt_raw.contentOffset = CGPointZero;
    
    
    
    /* Segunda parte. Pasar datos XML a Diccionario de Datos*/
    
    
    //Definicion de campos a procesar para el Diccionario de datos
    nivel1 = @"estatus,mensaje,Palabra_Com,Pos_ini,Pos_fin,Cuantos";
    nivel2 = @"Cliente_id,Nombre,Apellidos,Pais,Activo";
    
    //Conversion
    NSData* data = [xmlOUTPUT dataUsingEncoding:NSUTF8StringEncoding];
    xmlLector = [[NSXMLParser alloc] initWithData:data];
    xmlLector.delegate = self;
    txt_finales.text = @"";
    if ([xmlLector parse]) {
        //NSLog(@"%@",xmlNivel1);
        txt_finales.text = [[NSString alloc] initWithFormat:@"Dicionario de Datos:\n\n%@",xmlNivel1 ];
        txt_finales.contentOffset = CGPointZero;
    }
    
}



- (NSString*)textToHtml:(NSString*)htmlString {
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    return htmlString;
}



-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!currentElementValue){
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    }else{
        [currentElementValue appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if([elementName isEqualToString:@"root"]){
        xmlNivel1 = [[NSMutableDictionary alloc] init];
    } else if([elementName isEqualToString:@"registro"]){
        xmlNivel2 = [[NSMutableDictionary alloc] init];
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    
    if ([nivel1 rangeOfString:elementName].location != NSNotFound){
        [xmlNivel1 setObject:currentElementValue forKey:elementName];
    }
    
    if ([nivel2 rangeOfString:elementName].location != NSNotFound){
        [xmlNivel2 setObject:currentElementValue forKey:elementName];
    }
    
    if ([elementName isEqualToString:@"registro"]) {
        id existingValue = [xmlNivel1 objectForKey:elementName];
        if (existingValue){
            aAux = (NSMutableArray *) existingValue;;
        }else{
            aAux = [[NSMutableArray alloc] init];
        }
        
        [aAux addObject:xmlNivel2];
        [xmlNivel1 setObject:aAux forKey:elementName];
    }
    
    
    currentElementValue = nil;
    
    
}









@end
