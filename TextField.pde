class TextField
{
  float x;
  float y;
  float w;
  float h;
  PFont font;
  PFont labelFont;
  String val;
  String label;
  
  int margin = 2;
  
  color fieldcolor;
  color labelcolor;
  color highlightcolor;
  color boxcolor;
  
  boolean active = false;
  
  boolean selected = false;
  
  boolean editing = false;
  
  String buffer = "";
  
  TextField(float x, float y, PFont font, PFont labelFont, String val, String label, color fieldcolor, color labelcolor, color highlightcolor, color boxcolor)
  {
     this.x = x;
     this.y = y;
     this.font = font; 
     this.labelFont = labelFont;
     this.val = val;
     this.label = label;
     this.fieldcolor = fieldcolor;
     this.highlightcolor = highlightcolor;
     this.labelcolor = labelcolor;
     
     this.h = font.width('a')*font.getSize()*1.7; //assuming font is 1.7 times as high as it is wide, for now
     updateWidth(); //based on the value it is storing
  }
  
  void draw()
  {
    
    textAlign(LEFT);
    textFont(font);
    strokeWeight(1);
    if(isSelected())
    {
      stroke(boxcolor);
      fill(highlightcolor);
      rect(x-margin, y-h, w+margin, h+margin);
    }
    if(isOver() && !clickLocked)
    {
      stroke(boxcolor);
      noFill();
      rect(x-margin, y-h, w+margin, h+margin);
    }
    
    fill(fieldcolor);
    if(editing)
    {
      text(buffer, x, y);
    }
    else
    {
      text(val, x, y);
    }
    
    textFont(labelFont);
    fill(labelcolor);
    text(label, x+w, y);
  }
  
  TextField setPosition(float x, float y)
  {
      this.x = x;
      this.y = y;
      return this;
  }
  
  TextField setPosition(PVector v)
  {
      return setPosition(v.x, v.y);
  }
  
  TextField setVal(String val)
  {
    this.val = val;
    updateWidth();
    return this;
  }
  
  void deleteOne()
  {
    if(!editing) //if you haven't started typing yet
    {
      buffer = "";
      editing = true;
    }
    if(buffer.length() > 0)
    {
      buffer = buffer.substring(0, buffer.length()-1);
    }
  }
  
  void editVal(char c)
  {
    if(!editing)
    {
      editing = true;
    }
    buffer = buffer + c;
  }
  
  String finalVal()
  {
     if(editing && buffer.length() > 0)
     {
       editing = false; 
       return buffer;
     } 
     else
     {
       editing = false; 
       return val;
     }
  }

  boolean isSelected()
  {
     return selected; 
  }
  
  boolean isOver()
  {
     return (mouseX > x && mouseX < x+w+margin && mouseY > y-h-margin && mouseY < y);

  }
  
  void setSelected(boolean selected)
  {
    this.selected = selected;
    buffer = new String("");
  }
  
  boolean isActive()
  {
     return active; 
  }
  
  void setActive(boolean active)
  {
    this.active = active;
  }
  
  void updateWidth()
  {
    w = 0;
    for(int i=0;i<val.length();i++)
    {
      w += font.width(val.charAt(i))*font.getSize();
    } 
  }
}
