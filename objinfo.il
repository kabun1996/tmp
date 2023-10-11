/*

Group           Custom IC, Cadence Design Systems
Language        SKILL
Revision No.    1.0
Date Created    29th Aug 2009
Last Modified   28th March 2011
Tested in       IC615-500-1
Lint score      98
Author          hcquek
Description:    This program will display obj info for sch/layout

***************************************************

SCCS Info: %Z% %M% %G%.%U% %I%

********************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any           *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.                             *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.              *
********************************************************************

Save this program as "objinfo.il" in your working directory
Then key in the following in the CIW input panel :
load("objinfo.il")

Press F5 to enable object info. Shift-F5 to disable it.

Modify the "User customization" section and change it according
to the cdf parameters used in the pdk

Lint score is 98/100 due to usage of global variables
*/


;;; Global variables
totalLabels=20
declare( myLabels_sch[totalLabels] )
declare( myLabels_lay[totalLabels] )

procedure( CCSobjInfo()
   prog( (cv selObj winBox edgeAdjustX edgeAdjustY textAdjust x y textSize
		infoList i hset labelSpacing)
      cv=geGetWindowCellView()
      CCSremoveInfo(cv)
      mouseSingleSelectPt()
      selObj=car(geGetSelSet())
      winBox=geGetWindowBox(hiGetCurrentWindow())
      
      edgeAdjustX=0.02 ; 2% of horizontal display size
      edgeAdjustY=0.04
      textAdjust=0.023 ; 2.3% of vertical display size
      x=leftEdge(winBox)+(rightEdge(winBox)-leftEdge(winBox))*edgeAdjustX
      y=topEdge(winBox)-(topEdge(winBox)-bottomEdge(winBox))*edgeAdjustY
      textSize=(topEdge(winBox)-bottomEdge(winBox))*textAdjust
     
      infoList=CCSgatherInfo(selObj cv)
      hset=geCreateHilightSet(cv list("text" "drawing") nil)
      hset->enable=t
      i=0           
      labelSpacing=1.5
         foreach( info infoList
            if( info != nil && stringp(cadr(parseString(info))) then
               case(cv~>cellViewType
                  ("schematic"
	             myLabels_sch[i]=geAddHilightLabel(hset x:y info 
					"lowerLeft" "R0" "roman" textSize t nil))
                  ("maskLayout"
                     myLabels_lay[i]=geAddHilightLabel(hset x:y info 
					"lowerLeft" "R0" "roman" textSize t nil))
               ) ;case
               y=y-textSize*labelSpacing
               i++
            ) ;if
         ) ;foreach
      return(t)
   ) ;prog
) ;procedure


procedure( CCSremoveInfo(cv)
   prog( ()
      case(cv~>cellViewType
         ("schematic"
            for(i 0 length(myLabels_sch)-1
               if( geIsValidHilightObject(myLabels_sch[i]) then
                  geDeleteHilightObject(myLabels_sch[i])
                  myLabels_sch[i]=nil
               ) ;if
            )) ;for
         ("maskLayout"
            for(i 0 length(myLabels_lay)-1
               if( geIsValidHilightObject(myLabels_lay[i]) then
                  geDeleteHilightObject(myLabels_lay[i])
                  myLabels_lay[i]=nil
               ) ;if
            )) ;for
      ) ;case   
      return(t)
   ) ;prog
) ;procedure

procedure( CCSgatherInfo(selObj cv)
   prog( (infoList temp mosWidth mosLength mosM mosFingers mosFingerWidth
		resR capC diodeBipArea bipEW x1 x2 y1 y2 area perimeter
		width length innerR outerR diameter circum tf layer purpose
		techPathList inPort inLine inLineList gdsNum gdsType layerMap
		objNum objType objMap inPortObj distX distY distDiag)
      infoList=list()
     

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;;                  User customization                      ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; Modify the section below according to pdk cdf parameters ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      mosWidth="w"
      mosLength="l"
      mosM="m"
      mosFingers="fingers"
      mosFingerWidth="fw"
      resR="r"
      capC="c"
      diodeBipArea="area"
      bipEW="Ewidth"

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; Modify the section above according to pdk cdf parameters ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


      ; general
      if( temp=CCScheckParam("libName") then 
		infoList=append1(infoList CCScreateString("Lib name" temp) ))
      if( temp=CCScheckParam("cellName") then 
		infoList=append1(infoList CCScreateString("Cell name" temp) ))
      if( temp=CCScheckParam("viewName") then 
		infoList=append1(infoList CCScreateString("View name" temp) ))
      if( temp=CCScheckParam("name") then 
		infoList=append1(infoList CCScreateString("Inst name" temp) ))
      if( cv~>cellViewType=="maskLayout" then
         if( temp=CCScheckParam("objType") then 
		infoList=append1(infoList CCScreateString("ObjType" temp) ))
         if( temp=CCScheckParam("pin") then 
		infoList=append1(infoList "DFII pin: Yes" ))
         if( temp=CCScheckParam("viaHeader~>viaDefName") then 
		infoList=append1(infoList CCScreateString("Via name" temp) ))
         if( temp=CCScheckParam("viaHeader~>overrideParams") then 
		infoList=append1(infoList CCScreateString("Override Parameters" temp) ))
	 if( temp=CCScheckParam("theLabel") then 
		infoList=append1(infoList CCScreateString("Label" temp) ))
         if( temp=CCScheckParam("lpp") then 
		infoList=append1(infoList CCScreateString("lpp" temp) ))
         if( temp=CCScheckParam("width") then 
		infoList=append1(infoList CCScreateString("width" temp) ))
         if( selObj~>objType == "layerBlockage" then
            if( temp=CCScheckParam("layer") then 
		infoList=append1(infoList CCScreateString("Layer" temp) ))
            if( temp=CCScheckParam("type") then 
		infoList=append1(infoList CCScreateString("Type" temp) ))
        
         ) ;if
         if( selObj~>objType == "rect" then
            temp=CCScheckParam("bBox")
            x1=leftEdge(temp)
            y1=bottomEdge(temp)
            x2=rightEdge(temp)
            y2=topEdge(temp)
            area=(x2-x1)*(y2-y1)
            perimeter=2*(x2-x1)+2*(y2-y1)
            width=min(x2-x1 y2-y1)
            length=max(x2-x1 y2-y1)
            infoList=append1(infoList CCScreateString("area" area))
            infoList=append1(infoList CCScreateString("perimeter" perimeter))
            infoList=append1(infoList CCScreateString("width" width))
            infoList=append1(infoList CCScreateString("length" length))
         ) ;if
         if( selObj~>objType == "ellipse" then
            temp=CCScheckParam("bBox")
            x1=leftEdge(temp)
            y1=bottomEdge(temp)
            x2=rightEdge(temp)
            y2=topEdge(temp)
            if( x2-x1 == y2-y1 then
               diameter=x2-x1
               area=3.142*(diameter/2)*(diameter/2)
               circum=3.241*diameter
               infoList=append1(infoList CCScreateString("diameter" diameter))
               infoList=append1(infoList CCScreateString("area" area))
               infoList=append1(infoList CCScreateString("circumference" circum))
            ) ;if
         ) ;if
         if( selObj~>objType == "donut" then
            if( innerR=CCScheckParam("innerRadius") then 
		infoList=append1(infoList CCScreateString("innerRadius" innerR) ))
            if( outerR=CCScheckParam("outerRadius") then 
		infoList=append1(infoList CCScreateString("outerRadius" outerR) ))
            infoList=append1(infoList CCScreateString("Width" outerR-innerR))
            area=3.142*(outerR*outerR - innerR*innerR)
            infoList=append1(infoList CCScreateString("Area" area))
         ) ;if

         if( selObj~>objType=="ruler" then
            distX=rightEdge(selObj~>bBox)-leftEdge(selObj~>bBox)
            distY=topEdge(selObj~>bBox)-bottomEdge(selObj~>bBox)
            when( distX!=0 && distY!=0 distDiag=sqrt(distX**2 + distY**2))
            cond( 
               (distX!=0 && distY!=0
                  infoList=append1(infoList CCScreateString("distX" distX))
                  infoList=append1(infoList CCScreateString("distY" distY))
                  infoList=append1(infoList CCScreateString("distDiag" distDiag))
               )
               (distX!=0 && distY==0
                  infoList=append1(infoList CCScreateString("distX" distX))
               )
               (distX==0 && distY!=0
                  infoList=append1(infoList CCScreateString("distY" distY))
               )
            ) ;cond
         ) ;if

         gdsNum=nil
         gdsType=nil
         objNum=nil
         objType=nil
         tf=techGetTechFile(cv)
	 layer=selObj~>layerName
	 purpose=selObj~>purpose
         case( dbGetDatabaseType()
            ("OpenAccess"
               techPathList=remove(tf~>fileName parseString(tf~>path "/"))
               layerMap=strcat("/" buildString(techPathList "/") "/" tf~>libName ".layermap")
               inPort=infile(layerMap)
               if( inPort then
                  while(gets(inLine inPort)
                     inLineList=parseString(inLine)
                     if( nth(0 inLineList)==layer && nth(1 inLineList)==purpose then
	                gdsNum=nth(2 inLineList)
			gdsType=nth(3 inLineList)
	             ) ;if
		  ) ;while
	       ) ;if
               objMap=strcat("/" buildString(techPathList "/") "/" tf~>libName ".objectmap")
               inPortObj=infile(objMap)
               if( inPortObj then
                  while(gets(inLine inPortObj)
                     inLineList=parseString(inLine)
                     case( length(inLineList)
                        (5
                           if( nth(1 inLineList)==selObj~>type && nth(2 inLineList)==selObj~>layer then
	                      objNum=nth(3 inLineList)
			      objType=nth(4 inLineList)
	                   ) ;if
                        ) ;5
                        (4
                           if( nth(0 inLineList)==selObj~>objType && nth(1 inLineList)==selObj~>type then
	                      objNum=nth(2 inLineList)
			      objType=nth(3 inLineList)
	                   ) ;if
                        ) ;4
                     ) ;case
		  ) ;while
	       ) ;if
	    ) ;openAccess
	    ("CDBA"
               if( layer && purpose then
	          gdsNum=techGetStreamNumber(tf list(layer purpose))
	          gdsType=techGetStreamDatatype(tf list(layer purpose))
               ) ;if
	    ) ;CDBA
         ) ;case
         if( gdsNum && gdsType then
            infoList=append1(infoList CCScreateString("gdsNum" gdsNum) )
	    infoList=append1(infoList CCScreateString("gdsType" gdsType) )
         ) ;if      
         if( objNum && objType then
            infoList=append1(infoList CCScreateString("objNum" objNum) )
	    infoList=append1(infoList CCScreateString("objType" objType) )
         ) ;if  

         if( temp=CCScheckParam("bBox") then 
		infoList=append1(infoList CCScreateString("bBox" temp) ))
         if( temp=CCScheckParam("xy") then 
		infoList=append1(infoList CCScreateString("Origin" temp) ))
         if( selObj~>objType == "pathSeg" || selObj~>objType == "path" then
            if( temp=CCScheckParam("route") then
               infoList=append1(infoList "Route : Yes" )
            else
               infoList=append1(infoList "Route : No" )    
            ) ;if
         ) ;if

      ) ;if

      if( temp=CCScheckParam("lvsIgnore") then 
		infoList=append1(infoList CCScreateString("lvsIgnore" temp) ))
      if( temp=CCScheckParam("orient") then 
		infoList=append1(infoList CCScreateString("orient" temp) ))
      if( temp=CCScheckParam("srcType") then 
		infoList=append1(infoList CCScreateString("Type" temp) ))
      if( temp=CCScheckParam("vdc") then 
		infoList=append1(infoList CCScreateString("vdc" temp) ))
      if( temp=CCScheckParam("idc") then 
		infoList=append1(infoList CCScreateString("idc" temp) ))
      if( temp=CCScheckParam("acm") then 
		infoList=append1(infoList CCScreateString("ac mag" temp) ))
      if( selObj~>srcType == "sine" then
         if( temp=CCScheckParam("freq") then 
		infoList=append1(infoList CCScreateString("Freq" temp) ))
         if( temp=CCScheckParam("va") then 
		infoList=append1(infoList CCScreateString("Amplitude" temp) ))
      ) ;if
      if( selObj~>srcType=="pulse" || selObj~>srcType=="exp" || selObj~>srcType=="bit" then
         if( temp=CCScheckParam("val0") then 
		infoList=append1(infoList CCScreateString("Low" temp) ))
         if( temp=CCScheckParam("val1") then 
		infoList=append1(infoList CCScreateString("High" temp) ))
         if( temp=CCScheckParam("pwlPeriod") then 
		infoList=append1(infoList CCScreateString("Period" temp) ))
         if( temp=CCScheckParam("tr") then 
		infoList=append1(infoList CCScreateString("Rise time" temp) ))
         if( temp=CCScheckParam("tf") then 
		infoList=append1(infoList CCScreateString("Fall time" temp) ))
      ) ;if	 
      if( selObj~>srcType=="pulse" || selObj~>srcType=="exp" then
         if( temp=CCScheckParam("pw") then 
		infoList=append1(infoList CCScreateString("Pulse width" temp) ))
      ) ;if
      if( temp=CCScheckParam("net~>name") then 
		infoList=append1(infoList CCScreateString("Net" temp) ))
      if( temp=CCScheckParam("model") then 
		infoList=append1(infoList CCScreateString("Model" temp) ))
      ; mos
      if( temp=CCScheckParam(mosWidth) then 
		infoList=append1(infoList CCScreateString("W" temp) ))
      if( temp=CCScheckParam(mosLength) then 
		infoList=append1(infoList CCScreateString("L" temp) ))
      if( temp=CCScheckParam(mosM) then 
		infoList=append1(infoList CCScreateString("m" temp) ))
      if( temp=CCScheckParam(mosFingers) then 
		infoList=append1(infoList CCScreateString("Fingers" temp) ))
      if( temp=CCScheckParam(mosFingerWidth) then 
		infoList=append1(infoList CCScreateString("fw" temp) ))
      ; resistor
      if( temp=CCScheckParam(resR) then 
		infoList=append1(infoList CCScreateString("R" temp) ))
      ; capacitor
      if( temp=CCScheckParam(capC) then 
		infoList=append1(infoList CCScreateString("C" temp) ))
      ; diode
      if( temp=CCScheckParam(diodeBipArea) then 
		infoList=append1(infoList CCScreateString("area" temp) ))
      ; npn and pnp : Emitter width
      if( temp=CCScheckParam(bipEW) then 
		infoList=append1(infoList CCScreateString("Emitter width" temp) ))
      return(infoList)
   ) ;prog
) ;procedure


procedure( CCScreateString(description info)
   prog( (temp)
      if( !stringp(info) then sprintf(info "%L" info))
      temp=strcat(description ": " info)
      return(temp)
   ) ;prog
) ;procedure

procedure( CCScheckParam(param)
   prog( (temp)
      temp=evalstring(strcat("selObj~>" param))
      if( temp && temp !="" then
         return(temp)
      else
         return(nil)
      ) ;if
   ) ;prog
) ;procedure

procedure( CCSobjInfoON()
   hiSetBindKey("Schematics" "<Btn1Down>" "CCSobjInfo()")
   hiSetBindKey("Layout" "<Btn1Down>" "CCSobjInfo()")
   printf("Object info enabled\n")
) ;procedure


procedure( CCSobjInfoOFF()
   hiSetBindKey("Schematics" "<Btn1Down>" "schSingleSelectPt()")
   hiSetBindKey("Layout" "<Btn1Down>" "mouseSingleSelectPt()")
   CCSremoveInfo(geGetWindowCellView())
   printf("Object info disabled\n")
) ;procedure


procedure( CCSdeselectAll()
   CCSremoveInfo(geGetWindowCellView())
   geDeselectAllFig()
) ;procedure


procedure( CCSlayZoomIn()
   CCSremoveInfo(geGetWindowCellView())
   hiZoomIn()
) ;procedure


procedure( CCSlayZoomInR()
   CCSremoveInfo(geGetWindowCellView())
   hiZoomRelativeScale(hiGetCurrentWindow() 2.0)
) ;procedure


procedure( CCSlayZoomOutR()
   CCSremoveInfo(geGetWindowCellView())
   hiZoomRelativeScale(hiGetCurrentWindow() 0.5)
) ;procedure

procedure( CCSfitAll()
   CCSremoveInfo(geGetWindowCellView())
   hiZoomAbsoluteScale(hiGetCurrentWindow() 0.9)
) ;procedure


CCSobjInfoON() ;Enable by default

hiSetBindKey("Schematics" "F8" "CCSobjInfoON()")
hiSetBindKey("Schematics" "Shift<Key>F8" "CCSobjInfoOFF()")
hiSetBindKey("Schematics" "DrawThru3" "CCSlayZoomIn()")
hiSetBindKey("Schematics" "Shift<Key>z" "CCSlayZoomOutR()")
hiSetBindKey("Schematics" "Ctrl<Key>z" "CCSlayZoomInR()")
hiSetBindKey("Schematics" "<Key>f" "CCSfitAll()")
hiSetBindKey("Layout" "F8" "CCSobjInfoON()")
hiSetBindKey("Layout" "Shift<Key>F8" "CCSobjInfoOFF()")
hiSetBindKey("Layout" "Ctrl<Key>d" "CCSdeselectAll()")
hiSetBindKey("Layout" "DrawThru3" "CCSlayZoomIn()")
hiSetBindKey("Layout" "Shift<Key>z" "CCSlayZoomOutR()")
hiSetBindKey("Layout" "Ctrl<Key>z" "CCSlayZoomInR()")
hiSetBindKey("Layout" "<Key>f" "CCSfitAll()")
