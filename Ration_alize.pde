String [][] csvSpend;
String [][] csvEarn;
String [][] csvName;
String [][] csv;
String []   PixelToState   = new String[1150*600];
String []   PixelToStateId = new String[1150*600];
PShape      USA;
PImage      Money          = loadImage("Dollars.jpg");
PImage      Gold           = loadImage("coin.png");
PImage      WallSize       = loadImage("Wallsize.jpg");
PImage      MoneyStack     = loadImage("Transparent_stack.png");
PImage      Start          = loadImage("start.png");
String      lines[]        = loadStrings("us-states-data.csv");
PFont       font;
float       deficit[]      = new float[10];
float       StateMoney[]   = new float[10];
int         RedColors[]    = {46,255,113,85,0,85,238,205,225,139};
int         GreenColors[]  = {139,150,113,26,104,107,238,155,222,69};
int         BlueColors[]   = {87,122,198,139,139,47,0,29,173,0}; 
int         iAlternate[]   = new int[10];
int         iBankrupt[]    = new int[10];
int         GoldCounter    = 10;
int         prevMouseX     = 0;
int         prevMouseY     = 0;
int         done           = 0;
int         csvWidth       = 0;
int         GlobalStatus   = 99;
int         GlobalCounter  = 0;
int         Clicks         = 0;
int         DeadStates     = 0;
int         rectSizeX=80;
int         rectSizeY=40;
boolean     gameStart = false;
int         stateTarget=11;
float       magnitude =77;
int         disaster =11;
float       timeMax=50000;
boolean     applyRandom=false;
float       StartMilis = 0;
float       EndMilis = 0;
float       CurrentMilis = 0;
String[]      calamities={"Earthquake","Unemployment crisis","Real estate crash","Tornado","Bailout of "};
String [] CompanyName ={"Enron","Exxon","Citigroup","Teco Energy","Capital One","US Steel", "Boeing","Walmart","Verizon","GM Motors"};
boolean setDisplay=false;



/*-----------------------------------------------------------------------------------*/
 
void setup() 
  {
    
   size(1150, 600);
   USA = loadShape("Blank_US_Map.svg");
   smooth();
   font = createFont("Segoe Print",20,true);
  }

/*-----------------------------------------------------------------------------------*/

void draw()
  {
  if (setDisplay){
      delay(2000);
      setDisplay=false;
      }
  float current=millis();
  if (current>40000)
    current=current%40000;
  current=current/100;
  float newTime= random(timeMax);
  
   if(GlobalStatus == 77)
     {
         background(WallSize);
          textFont(font,100);  
          fill(255,255,255);
          text("Game Over!",250,350);
          textFont(font,70);
          text("Your Score :" + (int)(EndMilis - StartMilis),200,450);
         return; 
     } 
   
   if(GlobalStatus == 99)
     {
     
     background(45);
     shape(USA, 0, 0);
  //     background(45);
     load_all_data_once();  
     save_states();
     calculate_deficit();
    }
 else
     {
     background(WallSize);
     shape(USA, 0, 0);
     if (GlobalStatus!=88)
       {
          imageMode(CORNER);
        
            image(Start,575,300,rectSizeX,rectSizeY);
//       rectMode(CENTER);
 //      rect(575,300,rectSizeX,rectSizeY);
       }
     }

  if( GlobalStatus == 88)//TopSpendingStates
    { 
      CurrentMilis = millis();
      if(DeadStates > 3)
        {
          GlobalStatus = 77;
          EndMilis = millis();
        }
      GlobalCounter++;
       
      if ((GlobalCounter % 60) == 0)
         {
           decrease_state_funds();
           GlobalCounter = 0;
         }

       drawTopSpendingStates();    
    }
    
    show_federal_fund();
    int pixel = mouseX + (mouseY * 1150);
    if (mouseX==prevMouseX && mouseY==prevMouseY)
      {      
       String stateName=PixelToState[pixel];
       if (stateName!=null)
         {             
          textFont(font,20);  
          fill(218,165,32);//255,255,255);
          text(stateName,1000,40);
          }
           
       if (GlobalStatus == 88)
         {
          show_state_graph();
         }
      }
      
      
       if (current>newTime && GlobalStatus==88){
  random_event();
  textFont(font,25);
  fill(205,25,23);
  StringBuffer fullDisText= new StringBuffer(calamities[disaster]);
  if (disaster==4)
  fullDisText.append(CompanyName[stateTarget]);
  text(fullDisText + "  in  "+csvSpend[stateTarget+6][0] +" . " + "Damage estimate "+ int(magnitude) +"% of state funds.",180,30);
  setDisplay=true;
  } 
  
      
      prevMouseX=mouseX;
      prevMouseY=mouseY;     
  }

/*-----------------------------------------------------------------------------------*/

void load_all_data_once()
  {
  if(done == 0)
    {    
     csvSpend = load("Spending.csv");
     csvEarn  = load("Revenue.csv");
   
     remove_dollar_sign(csvSpend);
     remove_dollar_sign(csvEarn);
    
    done = 1;
    }
  }

/*-----------------------------------------------------------------------------------*/

String [][] load(String filename)
  {
   int csvWidth = 0;
   String lines[] = loadStrings(filename);    

  //calculate max width of csv file
    for (int i=0; i < lines.length; i++)
      {
      String [] chars=split(lines[i],',');
      if (chars.length>csvWidth)
        {
        csvWidth=chars.length;
        }
      }

  //create csv array based on # of rows and columns in csv file
    csv = new String [lines.length][csvWidth];

  //parse values into 2d array
  for (int i=0; i < lines.length; i++) 
    {
    String [] temp = new String [lines.length];
    temp= split(lines[i], ',');
    for (int j=0; j < temp.length; j++)
      {
       csv[i][j]=temp[j];
      }
    }
    return csv;
  }
  
 /*-----------------------------------------------------------------------------------*/ 
 
 void drawTopSpendingStates()
    {
      textFont(font,20);
      fill(255,255,255);
      text("Score:" + (int)(CurrentMilis-StartMilis),550,550);
     int TempI;
     
     for( TempI = 6;TempI<16;TempI++)
       {
         PShape St = USA.getChild(csvSpend[TempI][8]);
           
          if (StateMoney[TempI - 6] < 60)// if (i<50)
             {
              if(iBankrupt[TempI - 6] == 1)
                  {
                   stroke(0,0,0);
                  fill(color(0,0,0));
                  }
             else      
                {   
                 if(iAlternate[TempI - 6] == 0)
                    {
                    stroke(0,0,0);
                    fill(color(0,0,0)); //  
                    iAlternate[TempI - 6] = 1;
                    }
                else
                  {
                   fill(color/*(i,10,10)); */(RedColors[TempI-6],GreenColors[TempI-6],BlueColors[TempI-6]));
                   stroke(RedColors[TempI-6],GreenColors[TempI-6],BlueColors[TempI-6]);//i,10,10);   
                   iAlternate[TempI - 6] = 0;            
                  }  
               }
             }
          else
           {   
            fill(color(RedColors[TempI-6],GreenColors[TempI-6],BlueColors[TempI-6]));//i,10,10));
            stroke(RedColors[TempI-6],GreenColors[TempI-6],BlueColors[TempI-6]);//i,10,10);         
           }
       
          St.disableStyle(); 
          shape(St, 0,0);
       }
    }
    
/*-----------------------------------------------------------------------------------*/

void save_states()
  {
  int TempI;
     
  for( TempI = 6;TempI<=56;TempI++)
     {
     if (TempI != 36)//washington dc
       {         
       PShape St = USA.getChild(csvEarn[TempI][4]);
       fill(color(201-TempI*3,10,10));
       St.disableStyle();
       stroke(201-TempI*3,10,10);
       shape(St, 0,0);
       }   
     }
      
  load_pixel_state_info();
     
  }
  
/*-----------------------------------------------------------------------------------*/  
  
void load_pixel_state_info()
    {
     int r,g,b;
     int iWhichState;
      
     loadPixels();

      for (int k=0;k<pixels.length;k++)
        {
          color cinfo = pixels[k];

          if(cinfo == -13816531)
            continue;
 
            {
             r = (cinfo >> 16) & 0xFF;  
             g = (cinfo >> 8) & 0xFF; 
             b = cinfo & 0xFF;         

              iWhichState = (201-r)/3;
               if (iWhichState < 57 && iWhichState > 5)
                 {

                  PixelToStateId[k] = csvEarn[iWhichState][4]; 
                  PixelToState[k] = csvEarn[iWhichState][0]; 
                 }
                else
                  {
                    continue;
                  }
            }
        
      }
        GlobalStatus = 100;

      USA.enableStyle();
    
    }
    
/*-----------------------------------------------------------------------------------*/    

void mousePressed()
{
  
 
  int pixel = mouseX + (mouseY * 1150);
  println(PixelToState[pixel]);
  println(GlobalStatus);
  try{
  if(GlobalStatus == 88)
    {    
    for (int i=6 ; i<16 ; i++)
      {
      if (PixelToStateId[pixel].equals(csvSpend[i][8]))
           {
             if (iBankrupt[i-6] == 0)
               {
               Clicks++;
               println(Clicks);
               if (Clicks%10 == 0)
                {
                GoldCounter--;
        
                //Clicks = 0;
                }
               StateMoney[i - 6] += 50;
               iAlternate[i - 6] = 0;            
               break;
               }
           }
        }
    }
  
if( (gameStart == false) && mouseX > 575  && mouseX < 655  && mouseY > 300 && mouseY < 340)
    {
    /*  startH=hour();
      startM=minute();
      startS=second();*/
      gameStart = true;
    GlobalStatus = 88;      
    StartMilis = millis();
    }
  } catch(Exception e){
  System.out.println(e);}   
}

/*-----------------------------------------------------------------------------------*/

void mouseMoved()
{
   if(GlobalStatus != 77)
     {
     int pixel = mouseX + (mouseY * 1150);
     textFont(font,20);  
     fill(218,165,32);//255,255,255); 
     if(PixelToState[pixel] != null)
     text(PixelToState[pixel],1000,40); 
     if (GlobalStatus == 88)
      {
      show_state_graph();    
      }
    }
}

/*-----------------------------------------------------------------------------------*/

void remove_dollar_sign(String [][] Input)
  {
    int i,j;
    for (i=0 ; i< Input.length;i++)
      {
        for(j=0 ; j< Input[0].length;j++)
          {
            if (Input[i][j] != null)
               { 
               if(Input[i][j].length() > 0)
                  {
                  if(Input[i][j].charAt(0)== '$')
                      {
                      Input[i][j] = Input[i][j].substring(1);
                      }
                  }
              }
          }
      }
  }

/*-----------------------------------------------------------------------------------*/

void show_state_graph()
  {
   int i,j,Length; 
   int pixel = mouseX + (mouseY * 1150);
  
   if(PixelToStateId[pixel] != null)
    {
    String State = PixelToStateId[pixel];
    for( i=6;i<16;i++)
      {
      if(csvSpend[i][8].equals(State))
        {  
          Length = (int)(Float.parseFloat(csvEarn[i][1]));

        imageMode(CORNER);
        
        for (j=0 ; j<StateMoney[i-6]/13 ; j++)
          {
            image(MoneyStack,920,423 -20*j,100,120);
          }
         
         textFont(font,20);  
         fill(198,113,113);
         text("$Billion" + StateMoney[i-6],900,590); 
         text("State Funds",900,563);
         break;
        }
      } 
    }
  }

/*-----------------------------------------------------------------------------------*/

void show_federal_fund()
  {

   imageMode(CORNERS);
   
    int y = Clicks/16;
      
   for(int j=10 ; j> y ; j--)
      {
       image(Gold,1040 ,183+ 20*j,1140,403+20*j);            
      }
    
    fill(198,113,113);  
    text("$Billion" + (8000 - Clicks*50),1020,233+ 20*(10-GoldCounter));
    text("Federal",1055,575);
    text("Reserve",1055,595);
    if (5000 - Clicks * 50 == 0)
      {
        GlobalStatus = 77;
        EndMilis = millis();
      }
  }

/*-----------------------------------------------------------------------------------*/

void calculate_deficit()
   {
     for (int i = 6 ; i<16 ; i++)
       {
         iAlternate[i -6] = 0; // for the blinking; just put it here instead of using a for another for loop
         iBankrupt[i-6] = 0;;
         for (int j = 0 ; j < 25 ; j++)
           {
             if( csvSpend[i][0].equals(csvEarn[j][0]))
               {
                 deficit[i-6]    = Float.parseFloat(csvSpend[i][1]) - Float.parseFloat(csvEarn[j][1]);
                 StateMoney[i-6] = Float.parseFloat(csvEarn[j][1]);
               }
           }
       }
   }

/*-----------------------------------------------------------------------------------*/

void decrease_state_funds()
  {
    for (int i = 0 ; i < 10 ; i++)
      {
       if (iBankrupt[i] == 0)
         {
         StateMoney[i] =  StateMoney[i] - deficit[i];
         if (applyRandom && i==stateTarget){
         StateMoney[i]=StateMoney[i]*((100-magnitude)/100);
         System.out.println(i+ "targeted and State Money is" +StateMoney[i]);
         applyRandom=false;
         }
         if (StateMoney[i] <= 0)
           {
           iBankrupt[i] = 1;
           StateMoney[i] = 0;
           DeadStates++;
           }
         }
      }
  }
  
/*-----------------------------------------------------------------------------------*/
// Get a state to target 
// Get a magnitude of the event
// Get a random event
// Decrease the treasury
// Print the event
void random_event(){
  stateTarget=int(random(10));
  magnitude = random(20,40);
  disaster = int (random(5));
  if (iBankrupt[stateTarget]!=1)
    applyRandom=true;
  
  
}
