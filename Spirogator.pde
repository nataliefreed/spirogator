import controlP5.*;
import processing.pdf.*;
import java.text.DecimalFormat;

PGraphics pdf;
PGraphics png;

final int dpi = 72; //export resolution
final float page_w_in = 11; //width of exported page
final float page_h_in = 8.5; //height of exported page
final float page_w = page_w_in * dpi;
final float page_h = page_h_in * dpi;
final int menu_h = 200; //height of extra space for options menu
final int gr_menu_w = 200;
final int sr_menu_w = 400;
final int border = 30;
final int tab_h = 30;

final int SMALLEST_NUM_TEETH = 8;
final int OUTER_START = 125;
final int INNER_START = 30;
final int PENDIST_START = 75;
final float SPEED_START = 2.0;
final int PEN_WIDTH_START = 1;

float xOffset = 0;
float yOffset = 0;

float penWidth = PEN_WIDTH_START;

ControlP5 cp5;

DecimalFormat decimalFormat = new DecimalFormat("0.0");

int gearshape = 2;
boolean geartype = true;
float gearRadius = 100;
int numTeeth = 52;
float toothWidth = 10;
float toothHeight = 5;
boolean byRadius = false;
boolean nTeethSetInternal = false;
boolean radiusSetInternal = false;
float holeDist = 0;

float inner_angle = 0;
float outer_angle = 0;
float radians_per_frame = PI/256;
boolean paused = true;
//ArrayList<PGraphics> drawnLineCache;
PGraphics drawnLine;
PVector prevPoint = null;
PGraphics currentDrawnLine;
int angle_counter = 0;
float penDist = 0.5;
color penColor = color(0, 0, 255);

ArrayList<TextField> textfields;
TextField holeDistLabel;
TextField holeAngleLabel;
TextField numTeethLabel;
TextField gearRadiusLabel;

TextField outerNumTeethLabel;
TextField innerNumTeethLabel;
TextField simHoleDistLabel;
TextField simSpeedLabel; 
TextField penWidthLabel; 

GearedCircle active = null;
GearedCircle highlighted = null;
SpiroHole activeHole = null;
SpiroHole highlightedHole = null;
TextField activeText = null;

Textlabel htmGear;

GearedCircle outer;
GearedCircle inner;
float outerAngleCounter;

ArrayList<GearedCircle> gears;

boolean clickLocked = false;
boolean mouseReleased = false;
boolean isResizing = false;
boolean penOn = true;
boolean penChanged = true;
boolean steppingForward = false;

int numberOfPetals; //how many full rotations the inner gear will make before finishing the shape
int numberOfTurns; //how many times the inner gear will make a full rotation inside the outer gear before finishing the shape
float innerTurnCounter = 0;

PFont font;                          // STEP 2 Declare PFont variable

void setup()
{ 
  frame.setBackground(new java.awt.Color(0));

  size((int)(page_w+sr_menu_w), (int)(page_h+tab_h+2*border));

  font = createFont("Arial", 16, true);
  textFont(font, 16);

  gears = new ArrayList<GearedCircle>();
  drawnLine = createGraphics((int)(page_w), (int)(page_h + menu_h));

  textfields = new ArrayList<TextField>();

  resetParams();

  createMenu();

  showGearParams();

  createDrawingGears();
}

void draw()
{
  drawBackground();
  if (cp5.getTab("default").isActive())
  {
    drawGearMakerBackground();
    drawGearMakerForeground();
  }
  else
  {
    drawSimulatorBackground();
    drawSimulatorForeground();
  }
}

void drawBackground()
{
  background(0);
  fill(cp5.CP5BLUE.getActive());
  noStroke();
  rect(0, 30, width, height); //blue app background
}

void drawGearMakerBackground()
{
  fill(255);
  stroke(0);
  strokeWeight(1);
  rect(border, tab_h+border, page_w, page_h); //physical page to place gears on

  //Draw grid lines
  stroke(0, 0, 255, 50);
  int qt_in = dpi/4;
  for (int i=border+qt_in;i<page_w+border;i+=qt_in) //draw vertical 1/4 inch lines
  {
    line(i, tab_h+border, i, tab_h+page_h+border);
  }
  for (int i=tab_h+border+qt_in;i<page_h+border+tab_h;i+=qt_in) //draw horizontal 1/4 inch lines
  {
    line(border, i, page_w+border, i);
  }
  stroke(0, 50);
  for (int i=border+dpi;i<page_w+border;i+=dpi) //draw vertical 1 inch lines (bold)
  {
    line(i, border+tab_h, i, tab_h+page_h+border);
  }
  for (int i=tab_h+border+dpi;i<page_h+border+tab_h;i+=dpi) //draw horizontal 1 inch lines (bold)
  {
    line(border, i, page_w+border, i);
  }

  stroke(0);
  fill(200, 230);
  rectMode(CORNERS);
  rect(page_w+3*border, border+tab_h, width-border, height-border);  //draw menu bar
  fill(cp5.CP5BLUE.getBackground());
  rect(page_w+3*border, border+tab_h, width-border, tab_h+1.3*border); //draw top of menu bar
  rectMode(CORNER);

//  fill(0);
//  textAlign(LEFT);
//  textFont(font, 16);
//  text("Gear ", page_w+30, 80);
//  textFont(font, 14);
//  text("Number of teeth: ", page_w+50, 100);
//  text("Radius: ", page_w+50, 120);
//
//  textFont(font, 16);
//  text("Hole ", page_w+30, 150);
//  textFont(font, 14);
//  text("% of radius: ", page_w+50, 170);
//  text("Along angle: ", page_w+50, 190);

  if (gears.size() <= 0)
  {
    fill(0, 200);
    textFont(font, 20);
    textAlign(CENTER);
    text("Double click to draw a gear!", page_w/2+border, page_h/2+tab_h+border-20);
  }
  else if (gears.size() == 1)
  {
    if (gears.get(0).holes.size() <= 0 && gears.get(0).is_inner)
    {
      fill(0, 200);
      textFont(font, 20);
      textAlign(CENTER);
      GearedCircle t = gears.get(0);
      text("Double click on the gear\n to add a hole!", t.x, t.y + t.r + 40);
    }
    else if (gears.get(0).holes.size() == 1 && gears.get(0).holes.get(0).isNew)
    {
      fill(0, 200);
      textFont(font, 20);
      textAlign(CENTER);
      GearedCircle t = gears.get(0);
      text("Click and drag on a hole or gear to move it.", t.x, t.y + t.r + 40);
    }
  }
}
void drawSimulatorBackground()
{
  fill(255);
  stroke(0);
  strokeWeight(1);
  rect(border, tab_h+border, page_h, page_h); //physical page to place simulated gears on

  stroke(0);
  fill(200, 230); //gray menus
  rect(page_h+3*border, border+tab_h, width-page_h-4*border, 120); //menu bars
  rect(page_h+3*border, 2*border+tab_h+120, width-page_h-4*border, 330);
  rect(page_h+3*border, 3*border+tab_h+450, width-page_h-4*border, 100);
  fill(cp5.CP5BLUE.getBackground()); //top edges of menu bars
  rect(page_h+3*border, border+tab_h, width-page_h-4*border, 0.3*border);
  rect(page_h+3*border, 2*border+tab_h+120, width-page_h-4*border, 0.3*border); 
  rect(page_h+3*border, 3*border+tab_h+450, width-page_h-4*border, 0.3*border);
}

//  noStroke();
//  fill(cp5.CP5BLUE.getBackground());
//  rect(0, height-menu_h, width, menu_h);


void drawGearMakerForeground()
{ 

  if (activeHole != null)
  {
    drawHoleParams();
  }
  else
  {
    hideHoleParams();
  }

  if (active != null)
  {
    drawGearParams();
  }
  else
  {
    hideGearParams2();
  }

  if (highlighted != null && highlighted != active) highlighted.inactiveColor();
  highlighted = null;
  if (highlightedHole != null && highlightedHole != activeHole) highlightedHole.inactiveColor();
  highlightedHole = null;
  for (int i=0;i<gears.size();i++)
  {
    if (!clickLocked)
    {
      GearedCircle gear = gears.get(i);
      if (gear != active) { 
        gear.inactiveColor();
      }

      if (gear.checkOver())
      {
        for (int j=0;j<gear.holes.size();j++)
        {
          SpiroHole hole = gear.holes.get(j);
          if (hole.checkOver() && highlightedHole == null)
          {
            highlightedHole = hole;
            if (hole != activeHole) { 
              hole.highlightColor();
            }
          }
        }
        if (highlightedHole == null)
        {
          if (highlighted == null)
          {
            highlighted = gear;
            if (gear != active) { 
              gear.highlightColor();
            }
          }
          else if (gear.r < highlighted.r && highlightedHole == null) //prioritize smaller gears if mouse is over more than one gear, but only if we're not trying to select a hole
          {
            if (highlighted != active) { 
              highlighted.inactiveColor();
            }
            if (gear != active) { 
              gear.highlightColor();
            }
            highlighted = gear;
          }
        }
        //            for(int j=0;j<gear.holes.size();j++)
        //            {
        //               hole = gear.holes.get(j);
        //               if(hole != activeHole) 
        //            }
      }
    }
  }
  for (int i=0;i<gears.size();i++)
  {
    GearedCircle gear = gears.get(i);
    gear.draw(g);
  }
}  

void drawSimulatorForeground()
{   
   outerNumTeethLabel.draw();
   innerNumTeethLabel.draw();
   simHoleDistLabel.draw();
   simSpeedLabel.draw(); 
   penWidthLabel.draw();
//  println(outer_angle);
  if (!paused)
  {
    outer_angle += radians_per_frame;
    inner_angle = outer_angle*outer.num_teeth/inner.num_teeth - outer_angle;

    //        println(inner_angle);
    //  println(outer_angle);

    //      angle_counter = (angle_counter + 1) % (int) (outer.tooth_angle/radians_per_frame+0.5);
    //TODO: bug fix here!! divide by zero if gear is too fast and big, angles get too small

    SpiroHole innerHole = inner.holes.get(0);
    innerHole.updateCenter();
    innerHole.setTheta(-1*inner_angle);

    drawnLine.beginDraw();
    drawnLine.strokeWeight(penWidth);
    if (penOn && drawnLine != null)
    {
      drawnLine.stroke(penColor);
      PVector newPoint = fromPolar(inner.x, inner.y, inner.holes.get(0).rdist*inner.r, inner.holes.get(0).theta);
      if (penChanged)
      {  
        prevPoint = newPoint;
        penChanged = false;
      }
      drawnLine.line(prevPoint.x, prevPoint.y, newPoint.x, newPoint.y);
      prevPoint = newPoint;
      drawnLine.endDraw();
    }
  }

  if (prevPoint != null && drawnLine != null) { 
    image(drawnLine, 0, 0);
  }

  outer.draw(g);

  inner.setCenter(fromPolar(outer.x, outer.y, outer.r - inner.r, outer_angle)); 
  inner.setTheta(-1.0*inner_angle);
  inner.holes.get(0).setDist(penDist);
  inner.draw(g);
  line(inner.x, inner.y, fromPolar(inner.x, inner.y, inner.r, -1*inner_angle).x, fromPolar(inner.x, inner.y, inner.r, -1*inner_angle).y);
  
  if(!paused && (outer_angle - innerTurnCounter - radians_per_frame) / (2.0*PI) >= numberOfTurns) { pause(); }
  
  drawPetalsAndLaps();
}

void drawPetalsAndLaps()
{
  text("Number of petals: " + numberOfPetals, page_w+50, 110);
  text("Number of laps inside outer gear: " + numberOfTurns, page_w+50, 150);
}

void createDrawingGears()
{
  outer = new GearedCircle(border+page_h/2, tab_h+border+page_h/2, OUTER_START, 1, 10, 5, 2, false, false);
  inner = new GearedCircle(page_h/2, page_h/2, INNER_START, 1, 10, 5, 2, true, false);
  outer.inactiveColor();
  inner.inactiveColor();
  //    inner.addHole(0, 0);
  inner.addHole(PENDIST_START/100.0, 0);
  computePetals(); //update predicted number of petals drawn
}

public void toothWidthSlider(float val) {
  toothWidth = val;
  for (int i=0;i<gears.size();i++)
  {
    GearedCircle gear = gears.get(i);
    gear.setToothWidth(toothWidth);
  }
}

public void toothHeightSlider(float val) {
  toothHeight = val;
  for (int i=0;i<gears.size();i++)
  {
    GearedCircle gear = gears.get(i);
    gear.setToothHeight(toothHeight);
  }
}

public void exportButton(int theValue) {
//  pdf = createGraphics((int)(page_w), (int)(page_h), PDF, "cut file__" + timestamp() + ".pdf");
  pdf = createGraphics(16*dpi, 12*dpi, PDF, "cut file__" + timestamp() + ".pdf"); //Tinkering size
  pdf.beginDraw();
//  pdf.stroke(0);
  pdf.stroke(255, 0, 0); //for Tinkering lasercutter
  pdf.noFill();
  for (int i=0;i<gears.size();i++)
  {
    GearedCircle gear = gears.get(i);
    gear.draw(pdf);
  }
  pdf.dispose();
  pdf.endDraw();
}

public void makeGearButton(int theValue) {
  resetParams();
  GearedCircle g = new GearedCircle(width/2, (height-menu_h)/2, numTeeth, gearRadius, toothWidth, toothHeight, gearshape, geartype, byRadius);
  gears.add(g);
  if (active != null) { 
    active.inactiveColor();
  }
  active = g;
  active.activeColor();
  showGearParams();
}

public void duplicateGearButton(int theValue) {
  if (active != null)
  {
    GearedCircle gc = new GearedCircle(active);
    gears.add(gc); 
    active.inactiveColor();
    active = gc;
    active.activeColor();
  }
}

public void deleteGearButton(int theValue) {
  deleteActive();
}

void deleteActive()
{
  if (activeHole != null)
  {
    activeHole.gear.holes.remove(activeHole); //eep.
    activeHole = null;
  }
  else if (active != null)
  {
    gears.remove(active);
    //    hideGearParams();
    active = null;
  }
}

public void cutHoleButton(int theValue)
{
  if (active != null)
  {
    active.addHole(holeDist, 0);
  }
}

public void copyToGearMakerButton(int theValue)
{
  GearedCircle outerCopy = new GearedCircle(outer);
  GearedCircle innerCopy = new GearedCircle(inner);

  outerCopy.specialColor();
  innerCopy.specialColor();

  gears.add(outerCopy);
  gears.add(innerCopy);

  cp5.getTab("default").bringToFront();
}

public void rDistSlider(float val)
{
  if (activeHole != null)
  {
    activeHole.setDist(val);
  }
}

public void toothNumSlider(int val) {
  if (active != null)
  {
    if (!nTeethSetInternal) //make sure this was called by GUI event, rather than set internally eg. by the gear radius slider (TODO: actually could use setBroadcast)
    {
      numTeeth = val;
      byRadius = false;
      active.setNumTeeth(numTeeth);

//      Slider s = (Slider) cp5.getController("gearRadiusSlider");
//      radiusSetInternal = true;
//      s.setValue(active.r/dpi);
    }
    else
    {
      nTeethSetInternal = false;
    }
  }
}

public void gearRadiusSlider(float val) {
  if (active != null)
  {
    if (!radiusSetInternal)
    {  
      gearRadius = val;
      byRadius = true;
      active.setRadius(gearRadius*dpi);

//      Slider s = (Slider) cp5.getController("toothNumSlider");
//      nTeethSetInternal = true;
//      s.setValue(active.num_teeth);
    }
    else
    {
      radiusSetInternal = false;
    }
  }
}

public void rotationSpeedSlider(float val) {
  radians_per_frame = radians(val);
  simSpeedLabel.setVal(decimalFormat.format(val));
}

public void outerToothNumSlider(int val)
{
  if(outer != null)
  {
    outer.setNumTeeth(val);
//    println(lcm(outer.num_teeth, inner.num_teeth)/min(outer.num_teeth, inner.num_teeth));
    //  println(lcm(outer.num_teeth, inner.num_teeth));
    computePetals();
    outerNumTeethLabel.setVal(Integer.toString(val));
  }
}

public void innerToothNumSlider(int val)
{
  if(inner != null)
  {
    if(val > outer.getNumTeeth())
    {
      val = outer.getNumTeeth();
    }
    inner.setNumTeeth(val);
//    println();
    computePetals();
    //println(lcm(outer.num_teeth, inner.num_teeth));
    innerNumTeethLabel.setVal(Integer.toString(val));
  }
}

public void penWidthSlider(int val)
{
  penWidth = val;
  penWidthLabel.setVal(Integer.toString((int) val));
}

void computePetals()
{
  numberOfPetals = lcm(outer.num_teeth, inner.num_teeth)/min(outer.num_teeth, inner.num_teeth);
  numberOfTurns =  lcm(outer.num_teeth, inner.num_teeth)/max(outer.num_teeth, inner.num_teeth);
//  println("petals: " + numberOfPetals + " times around: " + numberOfTurns);

  innerTurnCounter = outer_angle; //inner_angle+outer_angle
//  println(innerTurnCounter);
}

public void holeDistField(String text)
{
  if (activeHole != null) { 
    activeHole.setDist(Float.parseFloat(text)/100);
  }
}

public void penDistFromCenter(float val)
{
  penDist = val/100.0;
  simHoleDistLabel.setVal(Integer.toString((int) val));
}


void activeToGlobal()
{
  if (active != null)
  {
    geartype = active.is_inner;
    gearRadius = active.r;
    numTeeth = active.num_teeth;
  }
}

void resetParams()
{
  //   gearshape = 2;
  geartype = true;
  gearRadius = 100;
  numTeeth = 52;
  toothWidth = 10;
  toothHeight = 5;
  byRadius = false;
}

void activeToSliders()
{
  if (active != null)
  {
//    Slider ts = (Slider) cp5.getController("toothNumSlider");
//    nTeethSetInternal = true;
//    ts.setValue(active.num_teeth);

//    Slider rs = (Slider) cp5.getController("gearRadiusSlider");
//    radiusSetInternal = true;
//    rs.setValue(active.r/dpi);

    Toggle os = (Toggle) cp5.getController("outOrInSelector");
    os.setBroadcast(false);
    os.setValue(active.is_inner);
    os.setBroadcast(true);
  }
}

void drawHoleParams()
{
  if (activeHole != null)
  {
    holeDistLabel.setPosition(fromPolar(activeHole.gear.x, activeHole.gear.y, activeHole.rdist*activeHole.gear.r/4*3, activeHole.theta));
    holeDistLabel.setVal(decimalFormat.format(activeHole.rdist * 100.0));
    holeDistLabel.setActive(true);
    holeDistLabel.draw();

    holeAngleLabel.setPosition(fromPolar(activeHole.gear.x, activeHole.gear.y, activeHole.gear.r/5, activeHole.theta-HALF_PI));
    holeAngleLabel.setVal(decimalFormat.format(degrees(activeHole.theta)));
    holeAngleLabel.setActive(true);
    holeAngleLabel.draw();
  }
}

void hideHoleParams()
{
  holeDistLabel.setActive(false);
  holeAngleLabel.setActive(false);
}

void drawGearParams()
{
  if (active != null)
  {
    numTeethLabel.setPosition(active.x-active.r/4, active.y-active.r-active.resizingBox.offset);
    numTeethLabel.setVal(Integer.toString(active.num_teeth));
    numTeethLabel.setActive(true);
    numTeethLabel.draw();

    gearRadiusLabel.setPosition(active.x+active.r/32, active.y-active.r/32);
    gearRadiusLabel.setVal(decimalFormat.format(inches(active.r)));
    gearRadiusLabel.setActive(true);
    gearRadiusLabel.draw();
  }
}

void hideGearParams2()
{
  numTeethLabel.setActive(false);
  gearRadiusLabel.setActive(false);
}

void sendText()
{
  if (activeText != null)
  {
    if (activeText == holeDistLabel && activeHole != null) //eep, ugly way of doing this
    {
      try
      { 
        activeHole.setDist(Float.parseFloat(activeText.finalVal())/100);
      } 
      catch(NumberFormatException e) {
      }
    }
    else if (activeText == holeAngleLabel && activeHole != null)
    {
      try { 
        activeHole.setTheta(radians(fmod(Float.parseFloat(activeText.finalVal()), 360.0)));
      } 
      catch(NumberFormatException e) {
      }
    }
    else if (activeText == numTeethLabel && active != null)
    {
      try
      { 
        active.setNumTeeth(Integer.parseInt(activeText.finalVal())); //update gear

//        Slider gr = (Slider) cp5.getController("gearRadiusSlider"); //update sliders
//        gr.setBroadcast(false);
//        gr.setValue(active.num_teeth); //update sliders
//        gr.setBroadcast(true);

//        Slider tn = (Slider) cp5.getController("toothNumSlider");
//        tn.setBroadcast(false);
//        tn.setValue(inches(active.r));
//        tn.setBroadcast(true);

        gearRadiusLabel.setVal(decimalFormat.format(inches(active.r))); //update radius according to gear's new values
      }
      catch(NumberFormatException e) {
      }
    }
    else if (activeText == gearRadiusLabel && active != null)
    {
      try { 
        active.setRadius(Float.parseFloat(activeText.finalVal()) * dpi);
        gearRadiusLabel.setVal(decimalFormat.format(inches(active.r))); //update radius to correct difference to make gear teeth even
        numTeethLabel.setVal(Integer.toString(active.num_teeth)); //update number of teeth accordingly
        
//        Slider gr = (Slider) cp5.getController("gearRadiusSlider"); //update sliders
//        gr.setBroadcast(false);
//        gr.setValue(active.num_teeth); //update sliders
//        gr.setBroadcast(true);
//
//        Slider tn = (Slider) cp5.getController("toothNumSlider");
//        tn.setBroadcast(false);
//        tn.setValue(inches(active.r));
//        tn.setBroadcast(true);
      }
      catch(NumberFormatException e) {
      }
    }
    else if(activeText == outerNumTeethLabel)
    {
      Slider s = (Slider) cp5.getController("outerToothNumSlider");
      try
      {
        int value = Integer.parseInt(activeText.finalVal());
        s.setValue(value);
        computePetals();
      }
      catch(NumberFormatException e) { }
    }
    else if(activeText == innerNumTeethLabel)
    {
      Slider s = (Slider) cp5.getController("innerToothNumSlider");
      try
      {
        int value = Integer.parseInt(activeText.finalVal());
        s.setValue(value);
        computePetals();
      }
      catch(NumberFormatException e) { }
    }
    else if(activeText == simHoleDistLabel)
    {
      Slider s = (Slider) cp5.getController("penDistFromCenter");
      try
      {
        int value = Integer.parseInt(activeText.finalVal());
        s.setValue(value);
        computePetals();
      }
      catch(NumberFormatException e) { }
    }
    else if(activeText == simSpeedLabel)
    {
      Slider s = (Slider) cp5.getController("rotationSpeedSlider");
      try
      {
        float value = Float.parseFloat(activeText.finalVal());
        s.setValue(value);
      }
      catch(NumberFormatException e) { }
    }
    else if(activeText == penWidthLabel)
    {
      Slider s = (Slider) cp5.getController("penWidthSlider");
      try
      {
        float value = Integer.parseInt(activeText.finalVal());
        s.setValue(value);
      }
      catch(NumberFormatException e) { }
    }

    activeText.setSelected(false);
    activeText = null;
  }
}


void keyPressed() {
  if (activeText != null)
  {
    if (key == '0' | key == '1' | key == '2' | key == '3' | key == '4' | key == '5' | key == '6' | key == '7' | key == '8' | key == '9' | key == '.')
    {
      activeText.editVal(key);
    }
    else if (key == BACKSPACE)
    {
      activeText.deleteOne();
    }
    else if (key == ENTER | key == RETURN) 
    {
      sendText();
    }
  }
  else if(key == 8)
  {
    deleteActive();
  }
  else if(key == 32 && cp5.getTab("simulator").isActive())
  {
    if(paused) play();
    else pause();
  }
}

void mouseReleased()
{
  mouseReleased = true;
  clickLocked = false;

  isResizing = false;

  //  if(activeHole != null) { ((Textfield) cp5.getController("holeDistField")).setFocus(true); } //avoids deleting hole by accident
}

void mousePressed()
{
  clickLocked = true;
  if (activeText != null)
  {
    if (!activeText.isOver()) //if you have just clicked away from the text field that was being edited
    {
      sendText();
      //TODO: reset, don't update, if you click away from the entire gear
    }
  }

  if(mouseEvent.getClickCount() == 2) //double click detected
  {
    TextField t = overText(); //if clicking on an active text field
    if (t != null)
    {
      t.setSelected(true);
      activeText = t;
    }
    else if(highlighted == null && !overMenu()  && cp5.getTab("default").isActive()) //if not clicking over a gear, make a new gear!
    {
      resetParams(); //reset gear parameters so new gears aren't duplicates of last gear
      GearedCircle g = new GearedCircle(mouseX, mouseY, numTeeth, gearRadius, toothWidth, toothHeight, gearshape, geartype, byRadius);
      gears.add(g);
      if (active != null) { 
        active.inactiveColor();
      } //TODO: make sure okay to remove. Shouldn't actually ever be the case since we clicked away from a gear
      active = g;
      active.activeColor();
      showGearParams();
    }
    else if(highlighted!= null && highlighted.distFromCenter(mouseX, mouseY) < highlighted.r - highlighted.tooth_h  && cp5.getTab("default").isActive()) //if you ARE double clicking on a gear, make a hole! Make sure hole can't be placed where teeth are.
    {
      if (active != null) { //gear is no longer active
        active.inactiveColor(); 
        active = null;
      }
      SpiroHole newHole = highlighted.addHoleXY(mouseX, mouseY); //draw hole at mouse location
      if (activeHole != null) activeHole.inactiveColor();
      activeHole = newHole;
      activeHole.activeColor();
    }
  }
  else if (overText() == null && cp5.getTab("default").isActive()) //Single click, not over a text field
  {
    if (active != null && !overMenu() && !active.checkOver()) //deselect if you click away from the selected/active gear, unless the click is on the menu
    {
      active.inactiveColor();
      active = null; 
      //      hideGearParams();
    }
    else if (activeHole != null && !overMenu() && !activeHole.checkOver() && cp5.getTab("default").isActive()) //deselect if you click away from the selected/active hole, unless the click is on the menu
    {
      activeHole.inactiveColor();
      activeHole = null; 
      //       hideHoleParams(); TODO
    } 

    //Okay, now we can check if one of the shapes is actually being clicked on

    if (highlightedHole != null) //if mouse is over a hole when pressed
    {
      if (active != null) { 
        active.inactiveColor(); 
        active = null;
      }
      if (activeHole != null) activeHole.inactiveColor();
      activeHole = highlightedHole;
      activeHole.activeColor(); 

      xOffset = mouseX - activeHole.x;
      yOffset = mouseY - activeHole.y;
    }
    else if (highlighted != null) //if mouse is over a gear when pressed (and it's not over a hole)
    { 
      if (highlighted != active) //if it's not already the one that's active
      {
        if (active != null) { 
          active.inactiveColor();
        }
        active = highlighted;
        active.activeColor();
        activeToGlobal();
        activeToSliders();
        showGearParams(); 

        xOffset = mouseX - active.x;
        yOffset = mouseY - active.y;
      }
    }
  }
}

boolean overMenu()
{
  if(cp5.getTab("default").isActive())
  {
    return (mouseX > page_w);
  }
  else return (mouseX > page_h);
}

void mouseDragged()
{
  if (active != null && !overMenu())
  { 
    if (isResizing)
    {
      active.setRadiusByMouse();
    }
    else if (active.resizingBox.isOver())
    {
      isResizing = true;
    }
    else
    {
      if (mouseReleased) //if just started dragging
      {
        xOffset = mouseX - active.x;
        yOffset = mouseY - active.y; 
        mouseReleased = false;
      }
      active.setCenter(mouseX - xOffset, mouseY - yOffset);
    }
  }
  else if (activeHole != null && !overMenu())
  {
    if (mouseReleased)
    {
      xOffset = mouseX - activeHole.x;
      yOffset = mouseY - activeHole.y; 
      mouseReleased = false;
    }
    activeHole.setDistByMouse();
  }
}

void outOrInSelector(int t) {
  geartype = (t==1)?true:false;
  if (active != null)
  {
    active.setGearType(geartype);
  }
}

void hideGearParams()
{
  //  Button gb = (Button) cp5.getController("makeGearButton");
  //  gb.show();

  //  Button cb = (Button) cp5.getController("cutHoleButton");
  //  cb.hide();
//  Slider ts = (Slider) cp5.getController("toothNumSlider");
//  ts.hide();
//  Slider rs = (Slider) cp5.getController("gearRadiusSlider");
//  rs.hide();
  Toggle os = (Toggle) cp5.getController("outOrInSelector");
  os.hide();
  Button cg = (Button) cp5.getController("duplicateGearButton");
  cg.hide();
  Button dg = (Button) cp5.getController("deleteGearButton");
  dg.hide();
}

void showGearParams()
{
  //  Button gb = (Button) cp5.getController("makeGearButton");
  //  gb.hide();

  //  Button cb = (Button) cp5.getController("cutHoleButton");
  //  cb.show();
//  Slider ts = (Slider) cp5.getController("toothNumSlider");
//  ts.show();
//  Slider rs = (Slider) cp5.getController("gearRadiusSlider");
//  rs.show();
  Toggle os = (Toggle) cp5.getController("outOrInSelector");
  os.show();
  Button cg = (Button) cp5.getController("duplicateGearButton");
  cg.show();
  Button dg = (Button) cp5.getController("deleteGearButton");
  dg.show();
}

void playButton()
{
  play();
}

void pauseButton()
{
  pause();
}

void pause()
{
  ((Button) cp5.getController("pauseButton")).hide();
  ((Button) cp5.getController("playButton")).show();
  paused = true;
  computePetals();
}

void play()
{
  ((Button) cp5.getController("playButton")).hide();
  ((Button) cp5.getController("pauseButton")).show();
  paused = false;
}

void clearScreenButton()
{
  drawnLine.background(0, 0); //don't use createGraphics((int)(page_w+sr_menu_w), (int)(page_h+tab_h+2*border)) (memory leak!)
  prevPoint = null;
  penChanged = true;
  computePetals();
}

void stepForwardButton() //go forwards one rotation of inner gear TODO
{
  //  rotationCounter = 0;
  //  steppingForward = true;
}

void stepBackButton() //go forwards one rotation of inner gear
{
}

void penButton()
{
  RadioButton r = (RadioButton) cp5.getGroup("penColorSelector");
  r.deactivateAll();
  penOn(false);
}

void drawingExportButton()
{
  png = createGraphics((int)(page_w), (int)(page_h), JAVA2D, "drawing.png");
  png.beginDraw();

  if (prevPoint != null) png.image(drawnLine, 0, 0);
  png.endDraw();

  png.save("drawing_" + outer.num_teeth + "_" + inner.num_teeth+ "___" + timestamp() + ".png");
}

void penColorSelector(int choice)
{
  if (choice == -1)
  {
    penOn(false);
  }
  else
  {
    penOn(true);
    RadioButton r = (RadioButton) cp5.getGroup("penColorSelector");
    penColor = r.getItem(choice).getColor().getActive();
  }
}

void penOn(boolean penOn)
{
  this.penOn = penOn;
  if (!penOn) penChanged = true;
}

void gearShapeSelector(int shape)
{
  gearshape = shape;
}

void createMenu()
{
  cp5 = new ControlP5(this);

  PFont p = createFont("Verdana", 10);
  cp5.setControlFont(p);

  cp5.addTab("simulator")
    //     .setColorBackground(color(0, 50))
    .setColorLabel(color(255))
      //     .setColorActive(color(255,128,0))
      .setLabel("make drawings")
        .activateEvent(true)
          .setId(2)
            .bringToFront()
              .setHeight(tab_h)
                .setWidth(130)
                  .getCaptionLabel().setFont(createFont("Verdana", 16)).toUpperCase(false)
                    ;


  cp5.getTab("default")
    .activateEvent(true)
      .setLabel("make gears")
        //     .setColorBackground(color(0, 50))
        .setId(1)
          .setHeight(tab_h)
            .setWidth(105)
              .getCaptionLabel().setFont(createFont("Verdana", 16)).toUpperCase(false)
                ;



//  cp5.addSlider("toothNumSlider", 10, 136, 10, 50, height-menu_h+20, 100, 14).setLabel("number of teeth").setSliderMode(Slider.FLEXIBLE).moveTo("default");
//  cp5.addSlider("gearRadiusSlider", 0.44, 6.0, 0.44, 50, height-menu_h+40, 100, 14).setLabel("radius").setSliderMode(Slider.FLEXIBLE).moveTo("default");

  //  cp5.addSlider("holeDistSlider", -1.0, 1.0, 0, 10, height-menu_h+170, 100, 14).setLabel("hole distance from center").setSliderMode(Slider.FLEXIBLE).moveTo("default");

  //  cp5.addSlider("toothWidthSlider", 5, 50, 10, 350, height-menu_h+50, 200, 14).setLabel("tooth width").setSliderMode(Slider.FLEXIBLE).moveTo("default");
  //  cp5.addSlider("toothHeightSlider", 2.5, 20, 5, 350, height-menu_h+70, 200, 14).setLabel("tooth height").setSliderMode(Slider.FLEXIBLE).moveTo("default");
  
//    rect(page_h+3*border, border+tab_h, width-page_h-4*border, 150); //menu bars
//  rect(page_h+3*border, 2*border+tab_h+150, width-page_h-4*border, 300);
//  rect(page_h+3*border, 3*border+tab_h+450, width-page_h-4*border, 100);
  
  outerNumTeethLabel =  new TextField(page_h+3*border+20, 2*border+tab_h+120+border+5, createFont("arial", 20), createFont("arial", 14), Integer.toString(OUTER_START), "", color(0), color(0), color(175, 175, 175), color(0, 255, 255));
  innerNumTeethLabel = new TextField(page_h+3*border+20, 2*border+tab_h+120+border+15+border+5, createFont("arial", 20), createFont("arial", 18), Integer.toString(INNER_START), "", color(0), color(0), color(175, 175, 175), color(0, 255, 255));
  simHoleDistLabel = new TextField(page_h+3*border+20+90, 2*border+tab_h+150+border+2*border+5, createFont("arial", 20), createFont("arial", 18), Integer.toString(PENDIST_START), "", color(0), color(0), color(175, 175, 175), color(0, 255, 255));
  simSpeedLabel =  new TextField(page_h+3*border+20+120+border, 2*border+tab_h+150+40+200+15, createFont("arial", 20), createFont("arial", 18), "5", "", color(0), color(0), color(175, 175, 175), color(0, 255, 255));
  penWidthLabel = new TextField(page_h+3*border+20, 2*border+tab_h+150+205, createFont("arial", 20), createFont("arial", 18), Integer.toString(PEN_WIDTH_START), "", color(0), color(0), color(175, 175, 175), color(0, 255, 255));
  outerNumTeethLabel.setActive(true);
  innerNumTeethLabel.setActive(true);
  simHoleDistLabel.setActive(true);
  simSpeedLabel.setActive(true);
  penWidthLabel.setActive(true);
  
  textfields.add(outerNumTeethLabel);
  textfields.add(innerNumTeethLabel);
  textfields.add(simHoleDistLabel);
  textfields.add(simSpeedLabel);
  textfields.add(penWidthLabel);
  
  
  cp5.addSlider("outerToothNumSlider")
     .setPosition(page_h+3*border+20, 2*border+tab_h+150+border-20)
     .setSize(400, 15)
     .setRange(SMALLEST_NUM_TEETH, 200)
     .setValue(125)
     .setLabel("outer gear teeth")
     .setSliderMode(Slider.FLEXIBLE)
     .moveTo("simulator")
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(40).setFont(createFont("Arial", 12)).toUpperCase(false).setColor(0)
     ;   
  cp5.getController("outerToothNumSlider").getValueLabel().hide();
  
  cp5.addSlider("innerToothNumSlider")
     .setPosition(page_h+3*border+20, 2*border+tab_h+150+border+15+border-20)
     .setSize(400, 15)
     .setRange(SMALLEST_NUM_TEETH, 200)
     .setValue(20)
     .setLabel("inner gear teeth")
     .setSliderMode(Slider.FLEXIBLE)
     .moveTo("simulator")
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(40).setFont(createFont("Arial", 12)).toUpperCase(false).setColor(0)
     ;
  cp5.getController("innerToothNumSlider").getValueLabel().hide();
  
  cp5.addSlider("penDistFromCenter")
     .setPosition(page_h+3*border+20, 2*border+tab_h+150+border+30+2*border-20)
     .setSize(400, 15)
     .setRange(0, 100)
     .setValue(75)
     .setLabel("pen point is at                 percent of radius")
     .setSliderMode(Slider.FLEXIBLE)
     .moveTo("simulator")
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0).setFont(createFont("Arial", 12)).toUpperCase(false).setColor(0)
     ;
  cp5.getController("penDistFromCenter").getValueLabel().hide();
  
    cp5.addSlider("rotationSpeedSlider")
     .setPosition(page_h+3*border+20+120+border, 2*border+tab_h+150+240+20)
     .setSize(250, 15)
     .setRange(0.0, 6.0)
     .setValue(SPEED_START)
     .setLabel("speed (degrees moved per frame)")
     .setSliderMode(Slider.FLEXIBLE)
     .moveTo("simulator")
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(35).setFont(createFont("Arial", 12)).toUpperCase(false).setColor(0)
     ;
  cp5.getController("rotationSpeedSlider").getValueLabel().hide();
  
  cp5.addSlider("penWidthSlider")
     .setPosition(page_h+3*border+20, 2*border+tab_h+150+210)
     .setSize(400, 15)
     .setRange(1, 40)
     .setValue(PEN_WIDTH_START)
     .setLabel("pen width in pixels")
     .setSliderMode(Slider.FLEXIBLE)
     .moveTo("simulator")
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(35).setFont(createFont("Arial", 12)).toUpperCase(false).setColor(0)
     ;
  cp5.getController("penWidthSlider").getValueLabel().hide();
  
  cp5.addButton("clearScreenButton")
    .setPosition(page_h+3*border+20, 2*border+tab_h+150+240)
      //    .setImages(loadImage("monitor.png"), loadImage("monitor.png"), loadImage("monitor.png"))
      .setLabel("Clear screen")
        .updateSize()
          .setSize(120, 40)
            .moveTo("simulator")
              .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER);



  cp5.addButton("exportButton")
    .setPosition(3*border+page_w+70, height-2*border-50)
      .setSize(150, 50)
        .setLabel("Export PDF (cut file)")
          .moveTo("default")
            .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER);
  ;

  cp5.addButton("copyToGearMakerButton")
    .setPosition(page_h+3*border+20, 3*border+tab_h+450+30)
      .setSize(190, 50)
        .setLabel("Copy gears to gear maker")
          .moveTo("simulator")
            .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER);

  cp5.addButton("drawingExportButton")
    .setPosition(page_h+3*border+250, 3*border+tab_h+450+30)
      .setSize(190, 50)
        .setLabel("Export PNG (drawing file)")
          .moveTo("simulator")
            .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER);

  //  cp5.addButton("makeGearButton")
  //    .setPosition(100, height-menu_h+45)
  //    .setSize(80, 20)
  //    .setLabel("make gear")
  //    .moveTo("default")
  //    ;

  cp5.addButton("deleteGearButton")
    .setPosition(page_w+4*border+80+border, tab_h+3*border+60)
      .setSize(70, 40)
        .setLabel("Delete")
          .moveTo("default")
          .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER)
            ;

  cp5.addButton("duplicateGearButton")
    .setPosition(page_w+4*border, tab_h+3*border+60)
      .setSize(80, 40)
        .setLabel("Duplicate")
          .moveTo("default")
          .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER)
            ;

  //  cp5.addButton("cutHoleButton")
  //    .setPosition(100, height-60)
  //    .setSize(65, 20)
  //    .setLabel("cut hole")
  //    .moveTo("default")
  //    ;

  cp5.addToggle("outOrInSelector")
    .setPosition(page_w+4*border, tab_h+2*border)
      .setSize(60, 30)
        .setValue(true)
          .setMode(ControlP5.SWITCH)
            .setLabel("Inner/Outer gear")
              .moveTo("default")
              .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).setColor(0)
                ;

  //  cp5.addRadioButton("gearShapeSelector")
  //    .setPosition(350, height-menu_h+90)
  //    .setSize(20, 20)
  //    //         .setColorForeground(color(120))
  //  //         .setColorActive(color(255))
  //  //         .setColorLabel(color(255))
  //  //         .setItemsPerRow(5)
  //  //         .setSpacingColumn(50)
  //  .addItem("outwards", 0)
  //    .addItem("inwards", 1)
  //    .addItem("both", 2)
  //    .moveTo("default")
  //    ;

  cp5.addButton("penButton")
    .setPosition(page_h+5*border+50*6, 2*border+tab_h+150+135)
      .setLabel("Pen up")
        .updateSize()
          .setSize(60, 40)
            .moveTo("simulator")
              .getCaptionLabel().setFont(createFont("Arial", 14)).toUpperCase(false).align(CENTER, CENTER);


  //      rect(page_h+3*border, border+tab_h, width-page_h-4*border, 150); //menu bars
  //  rect(page_h+3*border, 2*border+tab_h+150, width-page_h-4*border, 300);
  //  rect(page_h+3*border, 3*border+tab_h+450, width-page_h-4*border, 100);
  //.setPosition(page_h+4*border, 2*border+tab_h+150+230)


  RadioButton r = cp5.addRadioButton("penColorSelector")
    .setPosition(page_h+3*border+20, 2*border+tab_h+150+130)
      .setSize(50, 50)
        //         .setColorForeground(color(120))
        //         .setColorActive(color(255))
        //         .setColorLabel(color(255))
        .setItemsPerRow(7)
          .setSpacingRow(100)
            .addItem("red", 0)
              .addItem("orange", 1)
                .addItem("yellow", 2)
                  .addItem("green", 3)
                    .addItem("blue", 4)
                      .addItem("purple", 5)
                        .hideLabels()
                          .moveTo("simulator")
                            ;


  setRadioButtonColor(r, 0, color(255, 10, 10)); 
  setRadioButtonColor(r, 1, color(232, 133, 12)); 
  setRadioButtonColor(r, 2, color(232, 225, 12)); 
  setRadioButtonColor(r, 3, color(7, 129, 21)); 
  setRadioButtonColor(r, 4, color(3, 46, 255)); 
  setRadioButtonColor(r, 5, color(157, 3, 255)); 

  r.activate(0);
  r.activate(0);
  penColor = r.getItem(0).getColor().getActive();

  cp5.addButton("playButton")
    .setPosition(page_h+3*border+20, border+tab_h)
      .setImages(loadImage("play.png"), loadImage("play.png"), loadImage("play.png"))
        .updateSize()
          .moveTo("simulator");

  cp5.addButton("pauseButton")
    .setPosition(page_h+3*border+20, border+tab_h)
      .setImages(loadImage("pause.png"), loadImage("pause.png"), loadImage("pause.png"))
        .updateSize()
          .hide()
            .moveTo("simulator");


  //  cp5.addButton("stepForwardButton")
  //    .setPosition(110, height-menu_h+50)
  //    .setImages(loadImage("stepforward.png"), loadImage("stepforward.png"), loadImage("stepforward.png"))
  //    .updateSize()
  //    .moveTo("simulator");
  //
  //  cp5.addButton("stepBackButton")
  //    .setPosition(30, height-menu_h+50)
  //    .setImages(loadImage("stepback.png"), loadImage("stepback.png"), loadImage("stepback.png"))
  //    .updateSize()
  //    .moveTo("simulator");


  holeDistLabel = new TextField(100, 100, createFont("arial", 18), createFont("arial", 14), "10", "% of radius", color(255, 0, 0), color(0), color(175, 175, 175), color(0, 255, 255));
  holeAngleLabel = new TextField(150, 150, createFont("arial", 18), createFont("arial", 14), "90", "°", color(0, 0, 255), color(0), color(175, 175, 175), color(0, 255, 255));
  textfields.add(holeDistLabel);
  textfields.add(holeAngleLabel);

  numTeethLabel = new TextField(100, 100, createFont("arial", 22), createFont("arial", 18), "10", " teeth", color(255, 0, 0), color(0), color(175, 175, 175), color(0, 255, 255));
  gearRadiusLabel = new TextField(150, 150, createFont("arial", 18), createFont("arial", 14), "90", " inches", color(255, 0, 0), color(0), color(175, 175, 175), color(0, 255, 255));
  textfields.add(numTeethLabel);
  textfields.add(gearRadiusLabel);
}


void setRadioButtonColor(RadioButton r, int item, color c)
{
  color cf = color(c, 150);
  color cb = color(c, 50);
  r.getItem(item).setColorBackground(cb).setColorActive(c).setColorForeground(cf);
}

TextField overText()
{
  for (int i=0;i<textfields.size();i++)
  {
    TextField t = textfields.get(i);
    if (t.isOver() && t.isActive()) return t;
  }
  return null;
}

boolean isEnteringText()
{
  for (int i=0;i<textfields.size();i++)
  {
    TextField t = textfields.get(i);
    if (t.isSelected()) return true;
  }
  return false;
}


float fmod(float val, float max)
{
  if (val > max) { 
    val = val - ((int) (val/max))*max;
  }
  return val;
}

String timestamp()
{
  return year()+ "_" +month()+ "_" + day()+ "_" +hour()+ "_" +minute()+ "_" +second();
}

float inches(float pixels)
{
  return pixels / dpi;
}


//    locked = true; 
//    fill(255, 255, 255);
//  } else {
//    locked = false;
//  }
//  xOffset = mouseX-bx; 
//  yOffset = mouseY-by; 

int lcm(int a, int b) //least common multiple
{
  return a*b / gcd(a, b);
}

int gcd(int a, int b) //greatest common factor/divisor (Euclidean algorithm)
{
  if ((a % b) == 0) return b;
  else return gcd(b, a % b);
}

