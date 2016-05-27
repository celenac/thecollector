//jumping instructions: http://ashbprocessing.blogspot.com/2013/04/second-stage-character-jumping-platforms.html
//audio instructions: http://aaron-sherwood.com/processingjs/

int x, y, groundY;
int mainSize=10; //white square's width and height
int yinc; //speed of upthrust for character jump
int isjumping=0; //flag to know if character is jumping or not
boolean [] keys; //pressing two keys simultaneously
int collectablesArrayListSize=10;
ArrayList <Collectable> collectables =new ArrayList <Collectable>();
int [] randomYpositions;
int randomArrayLength; //number of platforms
int [] randomXpositions;
ArrayList <Enemy> enemies =new ArrayList <Enemy>();
int score=0;
boolean newLevel=true;
boolean gameOver=false;
int level=1;
int platformX;
int platformY;
int platformWidth=300;
color enemyColor=color(2,198,0);
color characterColor=color(255);
color collectableColor=color(255,0,0);
color groundColor=color(0);
color backgroundColor=color(200);
Audio jumpSound=new Audio(); //make new HTML5 audio object 
Audio collectSound=new Audio();
Audio touchSound=new Audio();

void setup()
{
  size(1000, 650);
  textAlign(CENTER);
  x=width/2;
  y=50;
  groundY=height-50;
  noStroke();
  keys=new boolean [3];
  keys[0]=false;
  keys[1]=false;
  keys[2]=false;

  createNewPlatformPositions(); 
  displayNewLevel();
  
  for (int c=0; c<collectablesArrayListSize; c++)
  {
    collectables.add(new Collectable());
  }

  for (int e=0; e<level; e++){
    enemies.add(new Enemy());
  }

  //load audio files
  jumpSound.setAttribute("src","jump.mp3");
  collectSound.setAttribute("src","wink.mp3");
  touchSound.setAttribute("src","rip.mp3");
}

void draw()
{
  background(backgroundColor);

  //set volume for sounds
  jumpSound.volume=1;
  collectSound.volume=1;
  touchSound.volume=1;

  //ground
  fill(groundColor);
  rect(-200, groundY, width+200, (height-groundY)+100);

  //drawing random platforms
  for (int i=0; i<randomArrayLength; i++)
  {
    fill(groundColor, 80); //platform shadow
    rect(randomXpositions[i]+4, randomYpositions[i]+4, platformWidth, 12,4);
    fill(groundColor);
    rect(randomXpositions[i], randomYpositions[i], platformWidth, 12,4);
  }

  //little box
  fill(0,80); //character shadow
  rect(x+4, y+4, mainSize, mainSize,3);
  fill(characterColor);
  rect(x, y, mainSize, mainSize,3);

  //wrapping around screen
  if (x>width-mainSize) {x=0;}
  if (x<0) {x=width-mainSize;}

  //show score
  textSize(25);
  textAlign(CENTER);
  fill(0,80); //text shadow
  text(score + "/" + collectablesArrayListSize, 42, 32);
  fill(0);
  text(score + "/" + collectablesArrayListSize, 40, 30);

  //show level
  textSize(20);
  textAlign(RIGHT);
  fill(0,80); //text shadow
  text("LVL "+level, width-10, 32);
  fill(0);
  text("LVL "+level, width-12, 30);

  //collectables
  for (int c=0; c<collectables.size(); c++)
  {
    collectables.get(c).show();
    collectables.get(c).scoring();
    if ((x==collectables.get(c).getX() || x==collectables.get(c).getX()+1 || x==collectables.get(c).getX()+2 || x==collectables.get(c).getX()+3 || x==collectables.get(c).getX()+5) && y==collectables.get(c).getY())
    {
      collectSound.currentTime=.25;
      collectSound.play();
      collectables.remove(c);
    }
  }
  checkNextLevel();
  if(newLevel==true){
    displayNewLevel();
  }

  //enemies
  for(int e=0; e<enemies.size(); e++){
    enemies.get(e).show();
    enemies.get(e).move();
  }

  //pressing two keys simultaneously
  if (keys[0]==true) {x=x+3;}
  if (keys[1]==true) {x=x-3;}

  //character jump
  if (keys[2]==true && isjumping==0)
  {
    jumpSound.play();
    isjumping=1;
    yinc=-15;
  }
  if ((isjumping==1 || get(x, y+10)!=groundColor)&&newLevel==false) //if character is jumping
  {
    y=y+yinc; //add thrust to current y position
    yinc=yinc+1; //-5,-4,-3,-2,-1,0,1,2
  }
  if (get(x, y+10)==groundColor)//if in range on the x axis of platform 
  {
    isjumping=0;
  }
  for (int w = 0; w < 10; w++) {
    if (get(x, y+w)==groundColor || get(x+10, y+w)==groundColor) {
      y--;
    } //makes character walk on the very surface after a jump
  }

  //game over: if character touches enemies
  for (int e=0; e<enemies.size(); e++)
  {
    for (int w = 0; w < mainSize; w++) {
      for (int h = 0; h < mainSize; h++) {
        if ((x==enemies.get(e).getX()+w) && y==enemies.get(e).getY()+h)
        {
          touchSound.currentTime=.5;
          touchSound.play();
          gameOver=true;
        }
      }
    }
  }
  if(gameOver==true){
    fill(0,125);
    rect(0,0,width,height);
    textAlign(CENTER);
    textSize(50);
    fill(0,80); //text shadow
    text("GAME OVER",width/2+4,height/2-46);
    fill(255);
    text("GAME OVER",width/2,height/2-50);
    textSize(20);
    fill(0,80); //text shadow
    text("~ YOUR LEVEL: "+level+" ~", width/2+4, height/2-6);
    fill(255);
    text("~ YOUR LEVEL: "+level+" ~", width/2, height/2-10);
    fill(0,80); //text shadow
    text("CLICK ANYWHERE TO PLAY AGAIN", width/2+4, height/2+24);
    fill(255);
    text("CLICK ANYWHERE TO PLAY AGAIN", width/2, height/2+20);
    for (int c=0; c<collectables.size(); c++){
      collectables.remove(c);
    }
    for (int e=0; e<enemies.size(); e++){
      enemies.remove(e);
    }
  }
}

 public void checkNextLevel(){
  if(gameOver==false){
    if(collectables.size()==0){
      level++;
      createNewPlatformPositions();
      for (int c=0; c<collectablesArrayListSize; c++)
      {
        collectables.add(new Collectable());
      }
      enemies.add(new Enemy());
      newLevel=true;
    }
  }
}

  public void displayNewLevel(){
    fill(0,125);
    rect(0,0,width,height);
    textAlign(CENTER);
    textSize(50);
    fill(0,80); //text shadow
    text("Level "+level, width/2+4, height/2-46);
    fill(255);
    text("Level "+level, width/2, height/2-50);
    textSize(20);
    fill(0,80); //text shadow
    text("CLICK ANYWHERE TO BEGIN",width/2+4,height/2+14);
    fill(255);
    text("CLICK ANYWHERE TO BEGIN",width/2,height/2+10);
    if(mousePressed==true){
      fill(0); //redraws the screen
      rect(0,0,width,height);
      y=groundY-10;
      x=width/2;
      newLevel=false;
      backgroundColor=color((int)(Math.random()*200)+50, (int)(Math.random()*200)+50, (int)(Math.random()*200)+50);
    }
  }

public int newRandInt(int tempVar, int maxValue){
  tempVar=(int)(Math.random()*maxValue);
  return tempVar;
}

public void createNewPlatformPositions(){
  randomArrayLength=(int)(Math.random()*5)+3;
  randomYpositions=new int [randomArrayLength];
  randomXpositions=new int [randomArrayLength];
  int i=1;
  randomXpositions[0]=(int)(Math.random()*(width-platformWidth));
  randomYpositions[0]=groundY-100;
  while(i<randomArrayLength)
  {
    do{
      platformX=newRandInt(platformX, width-platformWidth);
      randomXpositions[i]=platformX;
    }
    while(abs((randomXpositions[i]-randomXpositions[i-1]))>350);
    randomYpositions[i]=randomYpositions[i-1]-((int)(Math.random()*50)+50);
    i++;
  }
}

void mouseClicked(){
  if(gameOver==true){ //resets game
    collectablesArrayListSize=10;
    level=1;
    score=0;
    gameOver=false;
    newLevel=true;
    backgroundColor=color(200);
    createNewPlatformPositions(); 
    displayNewLevel();
    for (int c=0; c<collectablesArrayListSize; c++)
    {
      collectables.add(new Collectable());
    }

    for (int e=0; e<level; e++){
      enemies.add(new Enemy());
    }
    fill(0); //redraws the screen
    rect(0,0,width,height);
  }
}

void keyPressed()
{
  if(newLevel==false && gameOver==false){
    if (keyCode==RIGHT) {keys[0]=true;}
    if (keyCode==LEFT) {keys[1]=true;}
    if (keyCode==UP) {keys[2]=true;}
  }
  else{ //if transitioning levels, character cannot move
    if (keyCode==RIGHT) {keys[0]=false;}
    if (keyCode==LEFT) {keys[1]=false;}
    if (keyCode==UP) {keys[2]=false;}
  }
}

void keyReleased()
{
  if (keyCode==RIGHT) {keys[0]=false;}
  if (keyCode==LEFT) {keys[1]=false;}
  if (keyCode==UP) {keys[2]=false;}
}

class Collectable
{
  int collectableX, collectableY, randomIndex;
  Collectable()
  {
    randomIndex=(int)(Math.random()*randomArrayLength);
    collectableX=randomXpositions[randomIndex]+(int)(Math.random()*(platformWidth-10));
    collectableY=randomYpositions[randomIndex]-10;
  }
  void show()
  {
    fill(0,80); //collectable shadow
    rect(collectableX+4, collectableY+4, 10, 10,3);
    fill(collectableColor);
    rect(collectableX, collectableY, 10, 10,3);
  }
  void scoring()
  {
    if ((x==collectableX || x==collectableX+1 || x==collectableX+2 || x==collectableX+3 || x==collectableX+5) && y==collectableY)
    {
      score++;
    }
    if (newLevel==true){
      score=0;
    }
  }
  public int getX(){return collectableX;}
  public int getY(){return collectableY;}
}

class Enemy
{
  int enemyX, enemyY, randomIndex, enemyRandomDirection, enemy_isjumping, enemy_yinc;
  Enemy()
  {
    enemyRandomDirection=(int)(Math.random()*50)-26; //random negative or positive number generator
    enemyX=(int)(Math.random()*(width-10));
    enemyY=(int)(Math.random()*(groundY-10));
    enemy_isjumping=0; //flag to know when enemy is jumping or not
  }

  void show(){
    fill(0,80); //enemy shadow
    rect(enemyX+4, enemyY+4, 10, 10, 3);
    fill(enemyColor);
    rect(enemyX, enemyY, 10, 10, 3);
  }

  void move(){
    if(newLevel==false && gameOver==false){
      if(enemyRandomDirection<0){
        enemyX=enemyX-3;
      }
      else{
        enemyX=enemyX+3;
      }
      if(millis()%200==0){ //for every 100 milliseconds, generate a new random direction
        enemyRandomDirection=(int)(Math.random()*50)-26;
      }
      //enemy random jump
      if (millis()%500==0 && enemy_isjumping==0)
      {
        enemy_isjumping=1;
        enemy_yinc=-15;
      }
      if (enemy_isjumping==1 || get(enemyX, enemyY+10)!=groundColor) //if enemy is jumping
      {
        enemyY=enemyY+enemy_yinc; //add thrust to current enemyY position
        enemy_yinc=enemy_yinc+1; //-5,-4,-3,-2,-1,0,1,2
      }
      if (get(enemyX, enemyY+10)==groundColor)//if in range on the x axis of platform 
      {
        enemy_isjumping=0;
      }
      if (get(enemyX, enemyY+9)==groundColor || get(enemyX+10, enemyY+9)==groundColor) {
        enemyY--;
      } //makes enemy walk on the very surface after a jump
    }
    else{ //enemy doesn't move at the start of a level
      enemyX=enemyX+0;
    }


    //wrapping around screen
    if (enemyX>width-mainSize) {enemyX=0;}
    if (enemyX<0) {enemyX=width-mainSize;}
  }

  public int getX(){return enemyX;}
  public int getY(){return enemyY;}
}
