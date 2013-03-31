class ResizingBox
{
  float x;
  float y;
  float w;
  float h;
  float offset;
  
  color strokeColor;
  color fillColor;
  color activeColor;
  color activeFillColor;
  
  GearedCircle gear;
  
  ResizingBox(GearedCircle gear, color strokeColor, color fillColor, color activeColor, color activeFillColor)
  {
     this.gear = gear;
     updatePosition();
     
     this.w = 10;
     this.h = 10;
     
     updateBoundingBox();
    
     this.strokeColor = strokeColor;
     this.fillColor = fillColor;
     this.activeColor = activeColor;
     this.activeFillColor = activeFillColor;
  }
  
  void draw()
  {
    rectMode(CENTER);
    updatePosition();
    updateBoundingBox();
    strokeWeight(1);
    if(isOver()) // && clickLocked
    {
      stroke(activeColor);
      noFill();
      rect(gear.x, gear.y, (gear.r+offset)*2.0, (gear.r+offset)*2.0); //bounding box
      fill(activeFillColor);
      rect(x, y, w, h); //bottom left
      rect(x+(gear.r+offset)*2, y, w, h); //bottom right
      rect(x, y-(gear.r+offset)*2, w, h); //top left
      rect(x+(gear.r+offset)*2, y-(gear.r+offset)*2, w, h); //top right
    }
    else
    {
      stroke(strokeColor);
      noFill();
      rect(gear.x, gear.y, (gear.r+offset)*2.0, (gear.r+offset)*2.0); //bounding box
      fill(fillColor);
      rect(x, y, w, h); //small dragging box
      rect(x+(gear.r+offset)*2, y, w, h); //bottom right
      rect(x, y-(gear.r+offset)*2, w, h); //top left
      rect(x+(gear.r+offset)*2, y-(gear.r+offset)*2, w, h); //top right
    }
    rectMode(CORNER);
  }
  
  ResizingBox updatePosition()
  {
      this.x = gear.x - gear.r - offset;
      this.y = gear.y + gear.r + offset; //center of small dragging box at bottom left corner
      return this;
  }
  
  ResizingBox updateBoundingBox()
  {
     if(gear.is_inner) this.offset = 5 + gear.tooth_h/2;
     else this.offset = 5 + gear.tooth_h/2 + gear.outerCircleDist;
     return this;
  }

  boolean isOver()
  {
    return (overTopLeft() | overTopRight() | overBottomLeft() | overBottomRight());
  }
  
  boolean overBottomRight()
  {
    return (mouseX > x+(gear.r+offset)*2-w/2 && mouseX < x+(gear.r+offset)*2+w/2 && mouseY > y-h/2 && mouseY < y+h/2);
  }
  
  boolean overTopRight()
  {
    return (mouseX > x+(gear.r+offset)*2-w/2 && mouseX < x+(gear.r+offset)*2+w/2 && mouseY > y-(gear.r+offset)*2-h/2 && mouseY < y-(gear.r+offset)*2+h/2);
  }
  
  boolean overBottomLeft()
  {
    return (mouseX > x-w/2 && mouseX < x+w/2 && mouseY > y-h/2 && mouseY < y+h/2);
  }
  
  boolean overTopLeft()
  {
    return (mouseX > x-w/2 && mouseX < x+w/2 && mouseY > y-(gear.r+offset)*2-h/2 && mouseY < y-(gear.r+offset)*2+h/2);
  }
}
