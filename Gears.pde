class Circle
{
  float x;
  float y;
  float r;
  boolean over = false;
  boolean special = false;
  
  color strokeColor;
  int strokeWidth;
  color fillColor;
  boolean isNew = true;

  Circle(float x, float y, float r)
  {
    this.x = x;
    this.y = y;
    this.r = r;
  }

  void draw()
  {
    checkOver();
    ellipse(x, y, 2.0*r, 2.0*r);
  }

  boolean checkOver()
  {
//    float distX = x - mouseX;
//    float distY = y - mouseY;
//    float distFromCenter = sqrt(sq(distX) + sq(distY));
    over = (distFromCenter(mouseX, mouseY) < r);
    return over;
  }
  
  void setNew(boolean val)
  {
    isNew = val;
  }
  
  float distFromCenter(float x, float y)
  {
    float distX = this.x - x;
    float distY = this.y - y;
    float distFromCenter = sqrt(sq(distX) + sq(distY));
    return distFromCenter;
  }
  
  float getTheta(float x, float y)
  {
    return PI-atan2(this.y-y, this.x-x);
  }
  
  void setColor(color strokeColor, int strokeWidth, color fillColor)
  {
     this.strokeColor = strokeColor;
     this.strokeWidth = strokeWidth;
     this.fillColor = fillColor; 
  }
  
  void goColor()
  {
     stroke(strokeColor);
     strokeWeight(strokeWidth);
     fill(fillColor);
  }
  
  void highlightColor()
  {
    inactiveColor();
    setColor(strokeColor, 2, fillColor);
  }
  
  void activeColor()
  {
    setColor(color(255, 50, 50, 200), 2, color(255, 50, 50, 50));
    special = false;
  }
  
  void inactiveColor()
  {
    setColor(strokeColor, 1, fillColor); //TODO: make this more modular
    if(!special)
    {
      setColor(color(0, 200), 1, color(100, 50));
    }
  }
  
  void specialColor()
  {
    setColor(color(230, 182, 28, 200), 1, color(230, 182, 28, 100));
    special = true;
  }
}


class GearedCircle extends Circle
{
  float tooth_w;
  float tooth_h;
  float tooth_angle;
  int num_teeth;
  float sagitta; //distance between chord and center of arc
  int type;
  boolean is_inner;
  boolean byRadius;
  ArrayList<SpiroHole> holes;
  int outerCircleDist; //how far outer circle is drawn around an outer gear
  
  float theta; //angle entire gear is rotated to
  
  //types of gear tooth shapes
  final static int FLOWER = 0;
  final static int POINTY = 1;
  final static int WAVY = 2;
  
  boolean active = false;
  ResizingBox resizingBox;
  
  GearedCircle(float x, float y, int num_teeth, float r, float tooth_w, float tooth_h, int type, boolean is_inner, boolean byRadius)
  {  
    super(x, y, r);

    this.num_teeth = num_teeth;
    this.tooth_w = tooth_w;
    this.tooth_h = tooth_h;
    this.type = type;
    this.is_inner = is_inner;
    this.byRadius = byRadius; //true: set num teeth according to radius | false: set radius according to num teeth
    this.outerCircleDist = 50;
    this.theta = 0;
    

    holes = new ArrayList<SpiroHole>();
    
    resizingBox = new ResizingBox(this, color(255, 0, 0, 100), color(255, 255, 255, 150), color(255, 0, 0, 255), color(255, 0, 0, 50));
    
    activeColor();
    
    compute();
  }
  
  GearedCircle(GearedCircle gc)
  {
    this(gc.x, gc.y, gc.num_teeth, gc.r, gc.tooth_w, gc.tooth_h, gc.type, gc.is_inner, gc.byRadius);
    for(int i=0;i<gc.holes.size();i++)
    {
      holes.add(new SpiroHole(3, gc.holes.get(i).rdist, gc.holes.get(i).theta, this)); 
    }
    
  }

  void compute()
  {
    if(byRadius)
    {
      tooth_angle = 2*asin(tooth_w/(2.0*r)); //angle (that is fraction of full circle corresponding to location of tooth on edge) = 2 * arcsin (chord length / 2 * radius of big circle)
      //make sure tooth width divides evenly, change size of circle to fit number of teeth requested
      num_teeth = round(2*PI / tooth_angle);
    }
    
    if(num_teeth < SMALLEST_NUM_TEETH) num_teeth = SMALLEST_NUM_TEETH;  
    
    tooth_angle = 2.0*PI / num_teeth;
    r = 0.5*(tooth_w / sin(tooth_angle / 2.0)); //2r = chord length / sin(angle / 2)
     
    sagitta = r*(1-cos(tooth_angle/2)); //distance between center of chord and highest point of arc
  }
  
  void checkCanvasBoundsSize() //TODO
  {
//    if(x+r+tooth_h/2 > width) r = width-;
//    if(x-r-tooth_h/2 < 0) x = r+tooth_h/2;
//    if(y+r+tooth_h/2 > height) y = height-r-tooth_h/2;
//    if(y-r-tooth_h/2 < 0) y = r+tooth_h/2;
  }
  
  void highlightColor()
  {
    super.highlightColor();
    active = false;
  }
  
  void inactiveColor()
  {
    super.inactiveColor();
    active = false;
  }
  
  void activeColor()
  {
    super.activeColor();
    active = true;
  }

  PVector center() { 
    return new PVector(x, y);
  }
  
  void setCenter(float x, float y)
  {
    this.x = x;
    this.y = y; 
  }
  
  void checkCanvasBoundsCenter()
  {
    if(x+r+tooth_h/2 > width) x = width-r-tooth_h/2;
    if(x-r-tooth_h/2 < 0) x = r+tooth_h/2;
    if(y+r+tooth_h/2 > height) y = height-r-tooth_h/2;
    if(y-r-tooth_h/2 < 0) y = r+tooth_h/2;
  }
  
   void setCenter(PVector c)
  {
    setCenter(c.x, c.y);
  }
  
  void setNumTeeth(int new_num_teeth)
  {
    byRadius = false;
    num_teeth = new_num_teeth;
    compute();
  }
  
  int getNumTeeth()
  {
    return num_teeth;
  }
  
  void setRadius(float new_radius)
  {
    byRadius = true;
    r = new_radius;
    compute();
  }
  
  void setTheta(float theta)
  {
    if(is_inner) //outer gears just don't get to rotate, for now
    {
       this.theta = theta; 
    }
  }
  
  void setGearType(boolean gearType)
  {
    is_inner = gearType;
    if(!is_inner)
    {
       holes = new ArrayList<SpiroHole>(); 
    }
  }
  
  void setToothWidth(float new_tooth_w)
  {
    this.tooth_w = new_tooth_w;
    compute();
  }
  
  void setToothHeight(float new_tooth_h)
  {
   tooth_h = new_tooth_h;
   compute(); 
  }
  
  boolean checkOver()
  {
    float distX = x - mouseX;
    float distY = y - mouseY;
    float distFromCenter = sqrt(sq(distX) + sq(distY));
    if(is_inner)
    {
      over = (distFromCenter < r+tooth_h);
    }
    else //outer gears have a hole in the middle, not selectable
    {
      over = (distFromCenter < (r + outerCircleDist) && distFromCenter > r-tooth_h);
    }
    
    if(resizingBox.isOver() && active) over = true; //another way of being over a gear, select resizing box when gear is already active
    
    return over;
  }
  
  void addHole(float rdist_percent, float theta) //TODO: check for duplicates
  {
    if(is_inner)
    {
      float rdist = rdist_percent*r;
      PVector h = PVector.add(center(), polarPVector(rdist, theta));
      holes.add(new SpiroHole(3, rdist, theta, this));
    }
  }
  
  SpiroHole addHoleXY(float x, float y) //TODO: check for duplicates
  {
    if(is_inner)
    {
      float rdist = distFromCenter(x, y)/r;
      float theta = getTheta(x, y);
      SpiroHole hole = new SpiroHole(3, rdist, theta, this);
      holes.add(hole);
      return hole;
    }
    else return null;
  }
  
   void setRadiusByMouse()
  {
    float distFromCenter = distFromCenter(mouseX, mouseY);
    distFromCenter -= sqrt(2) * (resizingBox.offset + r) - r;//hypotenuse of an isoceles triangle is sqrt(2) times length of a side
    setRadius(distFromCenter);
    resizingBox.updatePosition();
  }

  void draw(PGraphics surface)
  {
//    setColor();
    //     ellipse(x, y, w, w); //draw circle inside of teeth

    if(active)
    {
       resizingBox.draw(); 
       line(new PVector(x, y), fromPolar(x, y, r, theta)); //draw in line for radius
    }

    goColor();
    
    switch(type)
    {
    case FLOWER:

      if (is_inner) //inner gear
      {            
        surface.beginShape();
        surface.vertex(toArray2d(fromPolar(x, y, r, 0)));
        for (float i=tooth_angle;i < 2.0*PI + 0.0001; i+=tooth_angle)
        {
          float angle_a = i-tooth_angle;
          float angle_b = i;

          PVector a = PVector.add(center(), polarPVector(r, angle_a));
          PVector b = PVector.add(center(), polarPVector(r, angle_b));

          // build the normal vector for the chord between the tooth endpoints
          PVector n = PVector.sub(b, a);
          n.normalize();
          n.rotate(PI/2);

          //find circle tangent to the sagitta to guide outer tooth as though it were converging on radius
          PVector guideCircle = PVector.add(center(), PVector.mult(n, 2.0*(r-sagitta)));

          PVector a_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_b));  //center point of new circle added to height of tooth at corresponding angle on new circle
          PVector b_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_a)); // note that angle_a/angle_b are swapped coming from the new circle

          surface.bezierVertex(a_outside.x, a_outside.y, b_outside.x, b_outside.y, b.x, b.y);
        }
        surface.endShape();
      }
      else //outer gear
      {
        ellipse(x, y, 2*r+2*outerCircleDist, 2*r+2*outerCircleDist);
//        circle(x, y, r+outerCircleDist);
        fill(255, 0);
        surface.beginShape();
        surface.vertex(toArray2d(fromPolar(x, y, r, 0))); 
        for (float i=tooth_angle;i < 2.0*PI + 0.0001; i+=tooth_angle)
        {
          float angle_a = i-tooth_angle;
          float angle_b = i;

          PVector a = PVector.add(center(), polarPVector(r, angle_a));
          PVector b = PVector.add(center(), polarPVector(r, angle_b));

          PVector a_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_a));
          PVector b_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_b));

          surface.bezierVertex(a_inside.x, a_inside.y, b_inside.x, b_inside.y, b.x, b.y);
        }

        surface.endShape();
        fill(fillColor);
      }
      break;

    case POINTY:
      if (is_inner) //inner gear
      {
        surface.beginShape();
        surface.vertex(toArray2d(fromPolar(x, y, r, 0)));
        for (float i=tooth_angle;i < 2.0*PI + 0.0001; i+=tooth_angle)
        {
          float angle_a = i-tooth_angle;
          float angle_b = i;

          PVector a = PVector.add(center(), polarPVector(r, angle_a));
          PVector b = PVector.add(center(), polarPVector(r, angle_b));

          PVector a_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_a));
          PVector b_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_b));

          surface.bezierVertex(a_inside.x, a_inside.y, b_inside.x, b_inside.y, b.x, b.y);
        }

        surface.endShape();
      }
      else
      {
        ellipse(x, y, 2.0*(r+outerCircleDist), 2.0*(r+outerCircleDist));
        
        surface.beginShape();
        surface.vertex(toArray2d(fromPolar(x, y, r, 0)));
        for (float i=tooth_angle+theta;i < 2.0*PI + 0.0001+theta; i+=tooth_angle)
        {
          float angle_a = i-tooth_angle;
          float angle_b = i;

          PVector a = PVector.add(center(), polarPVector(r, angle_a));
          PVector b = PVector.add(center(), polarPVector(r, angle_b));

          // build the normal vector for the chord between the tooth endpoints
          PVector n = PVector.sub(b, a);
          n.normalize();
          n.rotate(PI/2);

          //find circle tangent to the sagitta to guide outer tooth as though it were converging on radius
          PVector guideCircle = PVector.add(center(), PVector.mult(n, 2.0*(r-sagitta)));

          PVector a_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_b));  //center point of new circle added to height of tooth at corresponding angle on new circle
          PVector b_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_a)); // note that angle_a/angle_b are swapped coming from the new circle

          surface.bezierVertex(a_outside.x, a_outside.y, b_outside.x, b_outside.y, b.x, b.y);
        }
        surface.vertex(toArray2d(fromPolar(x, y, r, 0)));
        surface.endShape();
      }
      break;

    case WAVY:
      if (!is_inner) //draw an outline for an outer gear
      {
//          surface.ellipse(x, y, 2.0*(r+outerCircleDist), 2.0*(r+outerCircleDist));
          noStroke();
          beginShape();
          bezierCircleBackwards(x, y, r+outerCircleDist);
          
          for (float i=tooth_angle;i < 2.0*PI + 0.0001; i+=tooth_angle)
          {
            float delta = i;
            if(delta > 2.0*PI) { delta = 0; }
            float angle_a = delta-tooth_angle;
            float angle_b = delta-0.5*tooth_angle;
            float angle_c = delta;
    
            PVector a = PVector.add(center(), polarPVector(r, angle_a));
            PVector b = PVector.add(center(), polarPVector(r, angle_b));
            PVector c = PVector.add(center(), polarPVector(r, angle_c));
    
            // build the normal vector for the chord between the tooth endpoints
            PVector n = PVector.sub(c, b);
            n.normalize();
            n.rotate(PI/2);
    
            //find circle tangent to the sagitta to guide outer tooth as though it were converging on radius
            PVector guideCircle = PVector.add(center(), PVector.mult(n, 2.0*(r-sagitta)));
    
            PVector a_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_a));
            PVector b_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_b));
    
            PVector a_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_c)); // note that angle_a/angle_b are swapped coming from the toCircle
            PVector b_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_b));
             
            bezierVertex(a_inside.x, a_inside.y, b_inside.x, b_inside.y, b.x, b.y);
            bezierVertex(a_outside.x, a_outside.y, b_outside.x, b_outside.y, c.x, c.y);
          }
            endShape(CLOSE);
            stroke(strokeColor);
            noFill();
            surface.ellipse(x, y, 2.0*(r+outerCircleDist), 2.0*(r+outerCircleDist));
            
      }

      surface.beginShape();
      surface.vertex(toArray2d(fromPolar(x, y, r, theta)));
      float delta = theta + tooth_angle;
      for (float i=tooth_angle;i < 2.0*PI + 0.0001; i+=tooth_angle)
      {
        if(delta > 2.0*PI) { delta = delta - 2*PI; }
        float angle_a = delta-tooth_angle;
        float angle_b = delta-0.5*tooth_angle;
        float angle_c = delta;

        PVector a = PVector.add(center(), polarPVector(r, angle_a));
        PVector b = PVector.add(center(), polarPVector(r, angle_b));
        PVector c = PVector.add(center(), polarPVector(r, angle_c));

        // build the normal vector for the chord between the tooth endpoints
        PVector n = PVector.sub(c, b);
        n.normalize();
        n.rotate(PI/2);

        //find circle tangent to the sagitta to guide outer tooth as though it were converging on radius
        PVector guideCircle = PVector.add(center(), PVector.mult(n, 2.0*(r-sagitta)));

        PVector a_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_a));
        PVector b_inside = PVector.add(center(), polarPVector(r - tooth_h, angle_b));

        PVector a_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_c)); // note that angle_a/angle_b are swapped coming from the toCircle
        PVector b_outside = PVector.add(guideCircle, polarPVector(r - tooth_h, PI+angle_b));
         
        surface.bezierVertex(a_inside.x, a_inside.y, b_inside.x, b_inside.y, b.x, b.y);
        surface.bezierVertex(a_outside.x, a_outside.y, b_outside.x, b_outside.y, c.x, c.y);
        
        delta += tooth_angle;
      }
//      surface.vertex(toArray2d(fromPolar(x, y, r, theta)));
      surface.endShape();
//      line(x, y, fromPolar(x, y, r, 0).x, fromPolar(x, y, r, 0).y);
//      fill(255, 0, 0);
//      ellipse(fromPolar(x, y, r/3, 0).x, fromPolar(x, y, r/3, 0).y, 3, 3);
      noStroke();
      fill(fillColor, 1000);
      ellipse(x, y, 2, 2);
      stroke(strokeColor);
      fill(fillColor);
      break;
    default:
      break;
    }
    
    for(int i=0;i<holes.size();i++)
    {
      SpiroHole s = (SpiroHole) holes.get(i);
      PVector h = PVector.add(center(), polarPVector(s.rdist, s.theta));
      s.updateCenter();
      s.draw(surface);
    }

    //     for(float i=0;i<2*PI;i+=tooth_angle)
    //     {
    //        ellipse(fromPolar(x, y, w, h, i).x, fromPolar(x, y, w, h, i).y, tooth_w, tooth_w);
    //     }
  }
}

class SpiroHole extends Circle
{
  float rdist; //distance from center of circle
  float rdistP; //distance from center of circle as a percentage of radius
  float theta; //angle on outer circle
  GearedCircle gear;
  boolean active = false;
  boolean labelTeeth = false;
  
  SpiroHole(float r, float rdist, float theta, GearedCircle gear)
  {
    super(fromPolar(gear.x, gear.y, rdist*gear.r, theta).x, fromPolar(gear.x, gear.y, rdist*gear.r, theta).y, r);
    this.rdist = rdist;
    this.theta = theta;
    this.gear = gear;
    inactiveColor();
  }
  
  void updateCenter()
  {
    PVector center = fromPolar(gear.x, gear.y, rdist*gear.r, theta);
    x = center.x;
    y = center.y;
  }
  
  void setDist(float rdist)
  {
    if(rdist > 1.0) rdist = 1.0;
    if(rdist < 0.0) rdist = 0.0;
    this.rdist = rdist;
  }
  
  void setTheta(float theta)
  {
    this.theta = theta;
  }
  
  void labelTeeth(boolean labelTeeth)
  {
     this.labelTeeth = labelTeeth; 
  }
  
  void setDistByMouse()
  {
    if(isNew) setNew(false);
    float distFromCenter = gear.distFromCenter(mouseX, mouseY);
    if(distFromCenter > gear.r-gear.tooth_h) distFromCenter = gear.r-gear.tooth_h;
    if(distFromCenter < 0) distFromCenter = 0;
    
    setDist(distFromCenter/gear.r);
    setTheta(gear.getTheta(mouseX, mouseY));
    
    updateCenter();
  }
  
  boolean checkOver()
  {
    over = (distFromCenter(mouseX, mouseY) < r+2); //make it easier to select holes as they are small
    return over;
  }
  
   void setColor(color strokeColor, int strokeWidth, color fillColor)
  {
     this.strokeColor = strokeColor;
     this.strokeWidth = strokeWidth;
     this.fillColor = fillColor; 
  }
  
  void goColor()
  {
     stroke(strokeColor);
     strokeWeight(strokeWidth);
     fill(fillColor);
  }
  
  void highlightColor()
  {
    inactiveColor();
    active = true;
    setColor(color(0, 200), 3, fillColor);
  }
  
  void activeColor()
  {
    active = true;
    setColor(color(255, 50, 50, 255), 2, color(255, 50, 50, 255));
  }
  
  void inactiveColor()
  {
    active = false;
    setColor(color(0, 100), 1, color(0, 100));
  }
  
  void draw(PGraphics surface)
  {
    if(active)
    {
      strokeWeight(1);
      stroke(0, 100);
      line(gear.x, gear.y, fromPolar(gear.x, gear.y, gear.r, theta).x, fromPolar(gear.x, gear.y, gear.r, theta).y);
    }
    goColor();
    surface.ellipse(x, y, r*2.0, r*2.0);
  }
}

float[] toArray2d(PVector v) {
  float[] result = {
    v.x, v.y
  };
  return result;
}


void circle(PVector c, float r) {
  ellipse(c.x, c.y, 2.0*r, 2.0*r);
}

void line(PVector a, PVector b) {
  line(a.x, a.y, b.x, b.y);
}

void bezierVertex(PVector c1, PVector c2, PVector p) {
  bezierVertex(c1.x, c1.y, c2.x, c2.y, p.x, p.y);
}

PVector polarPVector(float r, float theta) {
  return new PVector(r*cos(theta), r*sin(-theta)); // negate y for left handed coordinate system
}

PVector fromPolar(float cx, float cy, float r, float theta)
{
  float px = r * cos(theta) + cx;
  float py = r * sin(-theta) + cy;

  return new PVector(px, py);
}

void bezierCircle(float x, float y, float r)
{
  float k = 4.0/3.0*(sqrt(2)-1);
//  beginShape();
  vertex(x+r, y);
  bezierVertex(x+r, y-r*k, x+r*k, y-r, x, y-r);
  bezierVertex(x-r*k, y-r, x-r, y-r*k, x-r, y);
  bezierVertex(x-r, y+r*k, x-r*k, y+r, x, y+r);
  bezierVertex(x+r*k, y+r, x+r, y+r*k, x+r, y);
//  endShape();
}

void bezierCircleBackwards(float x, float y, float r)
{
  float k = 4.0/3.0*(sqrt(2)-1);
  
  vertex(x+r, y);
  
  bezierVertex(x+r, y+r*k, x+r*k, y+r, x, y+r);
  bezierVertex(x-r*k, y+r, x-r, y+r*k, x-r, y);
  bezierVertex(x-r, y-r*k, x-r*k, y-r, x, y-r);
  bezierVertex(x+r*k, y-r, x+r, y-r*k, x+r, y);

}

//void dimensionLine(PVector start, PVector end, float size) //TODO: finish
//{
//  line(start.x, start.y-size, start.x, start.y+size); //vertical
//  line(start, fromPolar(start.x, start.y, size, PI/2); //top of arrow
//  line(start, fromPolar(start.x, start.y, size, PI/2);
//  
//  line(start, end);
//  
//  line(end.x, end.y-size, end.x, end.y+size); //vertical
//}
//
//void dimensionArc(PVector center, float r, float start, float stop) //TODO: finish
//{
//  arc(center.x, center.y, r*2, r*2, start, stop);
//}

