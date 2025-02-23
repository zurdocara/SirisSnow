#### voy a armar una puta función para pasar de jday a date y viceversa, 
# porque me tiene las bolas chatas encontrarme con este problema cada vez que hago esto
# 
# cat("Este script contiene funciones útiles para procesar datos de fecha, para transformar \n 
#     de julianos a Date a través de la función 'jd2date()' \n
#     y para transformar de Date a julianos a través de la función 'jd2date()'\n
#     En ambos casos solo nececito el vector de entrada donde están alojadas las fechas en uno u otro formato.\n")
# cat("También este Script posee un par de funciones para rellenar y filtrar series por medias móviles \n")
# cat("Desarrolladas por Leandro Cara.\n")


library(zoo)

# La fórmula lógica que se suele usar para establecer 
# si un año es bisiesto sería cuando [p y ¬q] ó [r] es verdadera, 
# pero esta otra p y [¬q ó r] sería más eficiente.
 
jd2date <- function(columna=vector()){
t1 <- vector()
    meses<- c(0,31,59,90,120,151,181,212,243,273,304,334,365)
  for( i in 1:length(columna)){
    x <- as.numeric(columna)[i]  
    year<- as.numeric(substr(x,1,4))
    diaj <- as.numeric(substr(x,5,7))
    if((year/4==round(year/4))&((year/100!=round(year/100))|(year/400==round(year/400)))& diaj>59&diaj){
      if(diaj==60){
        dia<- 29
        mes <-2
      }else{
        dia<- (diaj-1)-meses[tail(which((diaj-1)>meses),n=1)]
        mes <-tail(which((diaj-1)>meses),n=1)
        }
    }else{
      dia<- (diaj)-meses[tail(which((diaj)>meses),n=1)]
      mes <-tail(which(diaj>meses),n=1)
    }
  
  t1[i] <- paste(year,sprintf("%02d",mes),sprintf("%02d",dia),sep="-")
  
  }
    
  return(as.Date(t1))
}
  
date2jd <- function(columna=vector(),format="%Y-%m-%d"){
  t1 <- vector()
  meses<- c(0,31,59,90,120,151,181,212,243,273,304,334,365)
  formato <- c("%Y-%m-%d",### año adelante
               "%d-%m-%Y")### año atrás
  
  for( i in 1:length(columna)){
    x <-columna[i]  
    if(which(format==formato)==1){
      year<- as.numeric(substr(x,1,4))
      dia<- as.numeric(substr(x,9,10))
    }else{
      year<- as.numeric(substr(x,1,4))
      dia<- as.numeric(substr(x,9,10))
    }
    mes <- as.numeric(substr(x,6,7))
    x
    if((year/4==round(year/4))&((year/100!=round(year/100))|(year/400==round(year/400)))&((mes>=3))){
      t1[i]<- paste(year,sprintf("%03d",(dia+meses[mes]+1)),sep="")
    }else{
      t1[i]<- paste(year,sprintf("%03d",(dia+meses[mes])),sep="")
    }
  }
  return(t1)
}

MA.solo_filtra <- function(x=vector(),ventana=7,decimales=2){
  return(round(filter(x,filter=1/ventana*c(rep(1,ventana))),digits = decimales))
}

MA.rellena.filtra <- function(x=vector(),ventana=7,decimales=2){
  x<-na.approx(x, na.rm = FALSE)      # Interpolación (na.rm= F no elimina aquellos gaps donde no puede realizar interpolación)
  x <- round(filter(x,filter=1/ventana*c(rep(1,ventana))),digits = decimales)
  return(x)
}
############################################################################################################
  ############################ vamos a hacer un lindo gráfico de caudal

graf.ts.generic <- function(x,# tabla 
                         Date.column,# columna con las fechas
                         nro.fechas=10,
                         titulo=c("Titulo Genérico, por favor Cambiar"),
                         etiquetax="Date",
                         etiquetay=c("Data","Data.2"),
                         pasoh=10,
                         ruta=NULL,
                         leyenda=NULL,
                         ejes.sep=F,
                         sin.leyenda=T,
                         random.c=T,
                         ysim=F
                         ){
  library(randomcoloR)
  x <- as.data.frame(x)
  if(random.c=="b&n"){
    color <- c("grey","grey10","grey60")
  } else{
  color <- 1:6
  }
  if(random.c==T){
  color <- randomColor(length(x))
  }
  if(!is.null(ruta)) jpeg(ruta,
       width = 1600,height = 800,quality = 100)
  
  if(ejes.sep==F){
  mx <- max(na.omit(x[1:length(x)]))
  mn <- min(na.omit(x[1:length(x)]))
  if(ysim==T){
    mx<- max(c(abs(mx),abs(mn)))  
    mn<- mx*(-1)
  }
  }else{
  mx <- max(na.omit(x[,1]))
  mn <- min(na.omit(x[,1]))
  if(ysim==T){
    mx<- max(c(abs(mx),abs(mn)))  
    mn<- mx*(-1)
  }
  
  }
  par(mar=c(3,3,3,3))
  if(ejes.sep==F){
    plot(x[,1],type = "n",axes = F,ann=F,ylim=c(mn,mx),lwd=2)
  }else{
  plot(x[,1],type = "l",axes = F,ann=F,ylim=c(mn,mx),lwd=2,col=color[1])
  }
  axis(2)
  axis(1,seq(0,length(Date.column),length.out=nro.fechas),
       labels=Date.column[seq(1,length(Date.column),length.out=nro.fechas)])
  title(titulo)
  mtext(etiquetax,1,padj = 3)
  mtext(etiquetay[1],2,padj = -3)
  abline(v=seq(0,length(Date.column),length.out=nro.fechas),lty=2,col="grey")
  abline(h=seq(-1e6,1e6,pasoh),lty=2,col="grey")
  box()
  if(ejes.sep==F){
  for(i in 1:length(x)){
  points(x[i],type = "l",lwd=2,col=color[i])
  }
  }else{
  for(i in 2:length(x)){
    mx <- max(na.omit(x[,i]))
    mn <- min(na.omit(x[,i]))
    if(ysim==T){
      mx<- max(c(abs(mx),abs(mn)))  
      mn<- mx*(-1)
    }
  par(new=T)
  plot(x[,i],type = "l",axes = F,ann=F,ylim=c(mn,mx),col=color[i],lwd=2)##,lty=2)######
  }
  axis(4)
  mtext(etiquetay[2],4,padj = 3)
  
  }
  
  if(is.null(leyenda) & sin.leyenda==F){
   legend(0,mx,legend = names(x),lty=1,col=1:length(x))
  }else{
    if(!is.null(leyenda)){legend(0,mx,legend = leyenda, col=color[1:length(x)],pch=15,x.intersp = 1)}
  }
  if(!is.null(ruta)) dev.off()  
}
#####################################################################################
## Función para reproyectar shapes a UTM19S y a WGS84

reproy <- function(cca, sist = c("UTM19S"),verbose =T){
  if(verbose ==T){
  cat("\n")
  cat("Extent original del Shape \n")
  print(cca@bbox)
  }
  if(sist=="UTM19S"){
    cca <- spTransform(cca, CRS("+init=epsg:32719"))
    if(verbose ==T){
      cat("\n")
    cat("Extent del Shape en UTM 19S \n")
    print(cca@bbox)
    }
  }else{
    if(sist=="WGS84"){
      cca <- spTransform(cca, CRS("+init=epsg:4326"))
    if(verbose ==T){
      cat("\n")
      cat("Extent del Shape en  WGS84\n")
      print(cca@bbox)
    }
    }else{
      print("chequear formato de salida")
      break()
    }
  }
return(cca)
} 
###################################################################################
banner <- function(auto.off=T,tiempo=2){
  suppressWarnings(expr = x11(width = 17,height = 4))
  plot(1:100,type="n",ann=F,axes = F)
  legend(x = 15,130, legend = "TAREA",bty="n",cex = 7,text.col = "red")
  legend(x = 5,85, legend = "FINALIZADA",bty="n",cex = 7,text.col = "red")
  Sys.sleep(0.5)
  plot(1:100,type="n",ann=F,axes = F)
  legend(x = 15,130, legend = "TAREA",bty="n",cex = 7,text.col = "blue")
  legend(x = 5,85, legend = "FINALIZADA",bty="n",cex = 7,text.col = "blue")
  Sys.sleep(0.5)
  plot(1:100,type="n",ann=F,axes = F)
  legend(x = 15,130, legend = "TAREA",bty="n",cex = 7,text.col = "darkgreen")
  legend(x = 5,85, legend = "FINALIZADA",bty="n",cex = 7,text.col = "darkgreen")
  Sys.sleep(tiempo)
  if(auto.off==T) dev.off()
  }
#################
#### grafico para ver líneas de tiempo
series.temp <- function( x=data.frame(),### debería tener la columna de fecha adentro
                        Date.column,# especificar el nombre de la columna
                        nro.fechas=10,
                        titulo=c("Time Series"),
                        etiquetay=c("Data","Data.2"),
                    etiqueta=T,
                    subset.date=NULL
                    ){
  j <- 1
y<- which(names(x)==Date.column)
## pongo la fecha al principio
x <- x[,c(y,na.omit(as.numeric(gsub(paste("^",y,"$",sep=""),"",1:length(x)))))]

gr1 <- as.data.frame(x[,1])
for (i in names(x)[2:length(x)]){
  gr1[,i]<- MA.rellena.filtra(x[,i],ventana = 1 )
  gr1[which(!is.na(gr1[,i])),i] <- j
  j <- j+1
}

if (!is.null(subset.date)){
  inic<- subset.date[1]  
  fin<- subset.date[2]  
gr1 <- subset(gr1,gr1[,1]>=inic & gr1[,1]<=fin)
}  
#--------------------------------------------

fplot1 <- function(x,# tabla 
                  Date.column,# columna con las fechas
                  nro.fechas=10,
                  titulo=c("Titulo Genérico, por favor Cambiar"),
                  etiquetax="Date",
                  etiquetay=c("Data","Data.2"),
                  pasoh=10,
                  ruta=NULL,
                  leyenda=NULL,
                  sin.leyenda=T){
  library(randomcoloR)
  x <- as.data.frame(x)
    color <- randomColor(length(x))
    mx <- max(na.omit(x[1:length(x)]))
    mn <- min(na.omit(x[1:length(x)]))
      par(mar=c(3,3,3,3))

          plot(x[,1],type = "n",axes = F,ann=F,ylim=c(mn,mx+0.5),lwd=2)
  axis(1,seq(0,length(Date.column),length.out=nro.fechas),
       labels=Date.column[seq(1,length(Date.column),length.out=nro.fechas)])
    title(titulo)
    mtext("Date",1,padj = 3)
  abline(v=seq(0,length(Date.column),length.out=nro.fechas),lty=2,col="grey")
  box()
  
  for(i in 1:length(x)){
  dd <- which(!is.na(x[,i]))
      d1<- c(as.vector(x[1:dd[1],i]),na.omit(x[,i])[1]-0.1,na.omit(x[,i])[1]+0.1,
        as.vector(x[dd[1]:dd[length(dd)],i]),na.omit(x[,i])[1]-0.1,na.omit(x[,i])[1]+0.1)
      points(d1, type = "l",lwd=2,col=color[i])
 }
}

#--------------------------------------------
fplot1(x=gr1[,2:length(gr1)],
       Date.column=gr1[,1],
       titulo =titulo)

suppressWarnings(expr =if(etiqueta==T){
  text(x=length(rep(-1,length(gr1))), y=(1:(j-1))+0.1, pos=4, labels=names(x)[2:length(x)],cex=1.2)
} )
if(length(etiqueta)==length(x)-1){
 text(x=length(rep(-1,length(gr1))), y=(1:(j-1))+0.1, pos=4, labels=etiqueta,cex=1.2)
} 
}

############################################################################################################
############################ vamos a hacer un lindo gráfico de caudal

graf.ts.generic.2 <- function(x,# tabla 
                            Date.column,# columna con las fechas
                            nro.fechas=10,
                            titulo=c("Titulo Genérico, por favor Cambiar"),
                            etiquetax="Date",
                            etiquetay=c("Data","Data.2"),
                            pasoh=10,
                            ruta=NULL,
                            leyenda=NULL,
                            ejes.sep=F,
                            sin.leyenda=T,
                            random.c=T
){
  library(randomcoloR)
  x <- as.data.frame(x)
  if(random.c=="b&n"){
    color <- c("grey","grey10","grey60")
  } else{
    color <- c(1,2)
  }
  if(random.c==T){
    color <- randomColor(length(x))
  }
  if(!is.null(ruta)) jpeg(ruta,
                          width = 1600,height = 800,quality = 100)
  
  if(ejes.sep==F){
    mx <- max(na.omit(x[1:length(x)]))
    mn <- min(na.omit(x[1:length(x)]))
  }else{
    mx <- max(na.omit(x[,1]))
    mn <- min(na.omit(x[,1]))
  }
  par(mar=c(3,3,3,3))
  if(ejes.sep==F){
    plot(x[,1],type = "n",axes = F,ann=F,ylim=c(mn,mx),lwd=2)
  }else{
    plot(x[,1],type = "l",axes = F,ann=F,ylim=c(mn,mx),lwd=2,col=color[1])
  }
  axis(2)
  axis(1,seq(0,length(Date.column),length.out=nro.fechas),
       labels=Date.column[seq(1,length(Date.column),length.out=nro.fechas)])
  title(titulo)
  mtext(etiquetax,1,padj = 3,cex=0.5)
  mtext(etiquetay[1],2,padj = -3,cex=1)
  abline(v=seq(0,length(Date.column),length.out=nro.fechas),lty=2,col="grey")
  abline(h=seq(-1e6,1e6,pasoh),lty=2,col="grey")
  box()
  if(ejes.sep==F){
    for(i in 1:length(x)){
      points(x[i],type = "l",lwd=2,col=color[i])
    }
  }else{
    for(i in 2:length(x)){
      mx <- max(na.omit(x[,i]))
      mn <- min(na.omit(x[,i]))
      par(new=T)
      plot(x[,i],type = "l",axes = F,ann=F,ylim=c(mn,mx),col=color[i],lwd=2)##,lty=2)######
    }
    axis(4)
    mtext(etiquetay[2],4,padj = 3,cex=1)
    
  }
  
  if(is.null(leyenda) & sin.leyenda==F){
    legend(0,mx,legend = names(x),lty=1,col=1:length(x),cex=1,bty="n")
  }else{
    if(!is.null(leyenda)){legend(0,mx,legend = leyenda,
                                 col=color[1:length(x)],pch=15,x.intersp = 1,cex=1.2,bty="n")}
  }
  if(!is.null(ruta)) dev.off()  
}
#####################################################################################
rcl<- function(x,y){reclassify(x, y, include.lowest=FALSE, right=NA)}

corte <- function(x){substr(x,pos,pos+6)}
corte.x <- function(x,y=10,z=16,nom=T){ 
  while(grepl("/",x[1])){
    x<- substr(x,grep("/",x[1])+1,nchar(x))
  }
  if(nom){
    x<- substr(x,y,z)}
  return(x)
}
# lee archivos .tif de un directorio
f.1 <- function(x,y){
  x<- list.files(y,corte(x),full.names = T)
  return(x[grepl(x = x,pattern = ".tif$")])}
#########
#### 
m <- function(x){
  return(timestamp(quiet = T))
}
f.t2<- function(x){
  hh<- substr(x,21,22);mm<- substr(x,24,25);ss<- substr(x,27,28)
  hh[2]<- substr(x[2],21,22);mm[2]<- substr(x[2],24,25);ss[2]<- substr(x[2],27,28)
  hh <- as.numeric(hh);mm <- as.numeric(mm);ss <- as.numeric(ss);
  if((ss[2]-ss[1])>=0){ss[3] <- (ss[2]-ss[1])}else{ss[3] <- 60+(ss[2]-ss[1]);mm[1] <- mm[1]+1 }
  if((mm[2]-mm[1])>=0){mm[3] <-  mm[2]-mm[1]}else{mm[3] <-  60+(mm[2]-mm[1]);hh[1] <- hh[1]+1}
  if((hh[2]-hh[1])>=0){hh[3] <-  hh[2]-hh[1]}else{hh[3] <-  24+(hh[2]-hh[1])}
  return(paste(sprintf("%02d",hh[3]),sprintf("%02d",mm[3]),sprintf("%02d",ss[3]),sep=":"))
}
pr <- function(x){
  unique(getValues(x))
}
rp <- function(r){
  r<- projectRaster(r,crs =
                      "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs",
                    method = "ngb")
}

#############################################################################

dataFill <- function(x,pos=10,variante=NULL,lab="tif",verbose=T,relleno=0,max.data=NULL){
  
  #   # Función que rellena imágnes faltantes, encontradas en una serie por la función faltantes, (función recursiva ojo!!!)
  #       Argumentos:
  #         x= nombre de la subcarpeta donde se encuentran las imágenes
  #         path.out = donde se debe escribir la tabla de log
  #         pos= considerando la lista de imágenes,que todas poseen en una posición de su nombre el año y el día juliano juntos
  #               en que posición contando las letras se encuentra su inicio
  #         verbose= LOGICA, debe dar información de los procesos?
  
  # ############################### Vectores de prueba
  # x =dir.mod
  # verbose = T
  # lab = "missing.tif"
  # relleno=NA
  # djul=F
  # variante=NULL
  # # ############################################################
  d1 <- list()
  if(verbose==T){print("Función dataFill") 
    print(paste("Calculada para",x))
  }
  yy<- getwd()
  setwd(x)
  contador <- ifelse(is.null(variante),1,length(variante))
  
  y<- raster(list.files(x,pattern = ".tif")[1])
  rec <- as.matrix(data.frame(col1=pr(y),col2=rep(relleno,length(pr(y)))))
  y <- rcl(y,rec)
  
  for(VV in 1:contador){
    if(!is.null(max.data)){
      print("inicio de análisis:")
      print(corte.x(list.files(pattern=".tif$")[(length(list.files(pattern=".tif$"))-max.data)],
              nom=F))
    files.1 <- list.files(pattern=".tif$")[
      (length(list.files(pattern=".tif$"))-max.data):length(list.files(pattern=".tif$"))]
    }else{
    files.1 <- list.files(pattern=".tif$")
    }
    if(!is.null(variante)){
      files.1 <- files.1[grepl(variante[VV],files.1)]  
    }
    
    # Reviso si hay imágenes faltantes.----
    fal <- faltantes(x=files.1,pos=pos,djul = T,verbose=verbose,lab=lab)
    
    # Una vez verificado que faltan imágenes las genero como una capa uniforme de nubes.----
    if(is.null(fal)){
      if(verbose==T) cat("la serie se enceuntra completa!!! \n")  
      d1[[VV]] <- "serie completa"
    }else if(class(fal)=="Date"){
      if(verbose==T){ cat("la serie ha sido rellenada previamente, los valores rellnados son los siguientes: \n")  
        cat("\n")
        print(fal)}
      d1[[VV]]<- as.character(fal)
    }else{
      
      m.img<- paste(substr(files.1[[1]][1],0,pos-1),
                    fal$comparador,substr(files.1[[1]][1],pos+7,nchar(files.1[[1]][1])-4),".",
                    lab,sep="")
      
      if(verbose==T) print("Completando la información faltante")
      
      for (l in 1:length(m.img)) writeRaster(y,paste(x,"/",filename = m.img[l],sep=""),
                                             format="GTiff",datatype="INT1U", overwrite=T)
      
      if(verbose==T){ cat("Las imágenes faltantes en la serie analizada  son las siguientes: \n")
        print( paste("subset: ",variante[VV]))
        print(fal$fecha)}
      d1[[VV]]<- as.character(fal$fecha)
    }
    rm(fal)
  }
  names(d1) <- variante
  setwd(yy)
  return(d1)
}
#####################
##################### 
# Faltantes
### pregunta año biciesto
faltantes <- function(x=c(),pos=c(),djul=F,verbose=T,lab="missing.tif"){
  
  #    FECHA DE CREACIÓN: 19 de Noviembre de 2014
  #    AUTOR: Leandro Cara
  #    DESCRIPCIÓN  : En una tirada de datos de MODIS para bajar de eos, obtiene los años de las imágenes a descargar, cuantas 
  #    imágenes por año se tienen, cual es la primera y cual es la última imágen para descargar, y QUE IMÁGENES NO SE ENCUENTRAN EN
  #    LA SECUENCIA.
  #    ARGUMENTOS: 
  # x    = El objeto a analizar, este puede ser una matriz en la cual se va a analizar solo la primera columna, o un vector
  # pos  = es la posición dentro de la cadena de texto en la cual se debe comenzar a leer la fecha estructurada como año yyyy, 
  # día juliano ddd. La cadena será analizada como yyyyddd
  # djul = si el resultado de imagenes faltantes debe ser entregado como fecha gregoriana o día juliano anual.
  
  
  library(chron)
  # #   ############################# Variables de prueba
  # 
  #   x <- list.files(path=paste(startdir,"MOD10A1", sep="/"),pattern=".tif")  
  #   pos=10
  #   djul <- T
  #   verbose=T
  # ##########################################
  x <- as.data.frame(x)
  x[,1] <- as.character(x[,1])  
  nombres <- as.vector(x[,1])
  
  if(length(pos)==1){
    
    ### Armo una tabla con la pirmer columna de año y la segunda dia juliano, parto de los nombres
    img1 <- data.frame(year=as.numeric(substr(x[,1],pos,pos+3)),d_jul= as.numeric(substr(x[,1],pos+4,pos+6)))
    # saco la primera y última imagen de la serie
    img<- rbind(img1[1,],img1[length(img1[,1]),])
    # separo la primer tabla por año y los pongo separados en una lista
    img1<- split(img1,as.factor(img1$year))
    # obtengo un vector con los años  
    year <- seq(img[1,1],img[2,1])
    pr.1 <- data.frame()
    # para cada año
    for (i in 1:length(year)){
      # calculo si es año juliano
      if((year[i]/4==round(year[i]/4))&
         ((year[i]/100!=round(year[i]/100))|(year[i]/400==round(year[i]/400)))){
        y <- 366
      }else{
        y <- 365
      }
      # armo una tabla donde pongo para cada año el inicio y el fin
      # teniendo en cuenta si es el primer/último dato de la serie
      pr.1[i,1] <- year[i]
      ### dia inicio
      if(i==1){ 
        pr.1[i,2] <- img[1,2]
      }else{
        pr.1[i,2] <- 1
      }
      ### dia fin
      if(i==length(year)){ 
        pr.1[i,3] <- img[2,2]
      }else{
        pr.1[i,3] <- y
      }
    }
    # termina la tabla
    
    y <- data.frame()
    # para cada año 
    for (i in 1:length(pr.1[,1])){
      # armo una secuencia del primer al último día del año sacados de la tabla anterior 
      x <- seq(pr.1[i,2],pr.1[i,3])
      ## genero una nueva tabla con dos campos | año | día juliano -> este sale de la secuencia ant.
      y<-rbind(y,merge(year[i],x))
    }
    
    # serie completa
    # split a y
    a<- split(y,as.factor(y$x))
    
    ## completa con NA los días en que tengo escenas faltantes!!!!
    for (i in 1:length(a)){
      a[[i]][(match(img1[[i]][,2],a[[i]][,2])),3] <-img1[[i]][,2] 
    }
    # transforma la lista a tabla
    tabla <- data.frame()
    for(z in 1:length(a)) tabla <- rbind(tabla,a[[z]])
    
    # saca de la tabla una nueva tabla con los valores faltantes
    faltantes<- tabla[is.na(tabla[,3]),c(1,2)]
    # verifico si no hay valores faltantes: puede ser por dos motivos 
    # que esté completa la serie o que haya sido rellenada. buscaremos entonces 
    # la etiqueta "lab"
    
    if(length(faltantes$x)==0 & !any(grepl(lab,nombres))){
      if(verbose)  {print("serie completa")}
      faltantes <- NULL
    }else if (length(faltantes$x)==0 & any(grepl(lab,nombres))){
      if(verbose)  print("serie rellenada")
      faltantes <- jd2date(substr(nombres[grepl(lab,nombres)],pos,pos+6))
    }else{
      if(verbose) print("serie incompleta")
      faltantes$comparador<- paste(faltantes[,1],sprintf("%03d",faltantes[,2]),sep = "")
      faltantes$fecha<- jd2date(paste(faltantes[,1],sprintf("%03d",faltantes[,2]),sep = ""))
    }
    
    return(faltantes)
  }else{  print("Falta posicición de inicio de fecha"); print("Se define con el argumento pos")}
}
#############################
corx<- function(l.modis){
  x <- list()
  for( i in 1:4)
    x[[i]] <- corte.x(l.modis[[i]])
  return(x)
}

############################################################################################################
#####################
cero2NA<- function(x){reclassify(x,data.frame(cl1=0,cl2=NA), include.lowest=FALSE, right=NA)}
NA2cero<- function(x){reclassify(x,data.frame(cl1=NA,cl2=0), include.lowest=FALSE, right=NA)}
NA2count<- function(x){reclassify(x,data.frame(cl1=c(0,NA),cl2=c(255,NA),cl3=c(0,1)), include.lowest=FALSE, right=NA)}
dos2na <- function(x){reclassify(x,data.frame(cl1=2,cl2=NA), include.lowest=FALSE, right=NA)}
