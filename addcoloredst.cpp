

void graphicst::addcoloredst(const char *str, const char *colorstr)
{
    const int slen = strlen(str);
    changecolor((colorstr[0] & 7),((colorstr[0] & 56))>>3,((colorstr[0] & 64))>>6);
    string someBuf = str;
    addst(someBuf);
}

void graphicst::changecolor(short f,short b,char bright)
{
    screenf=f;
    screenb=b;
    screenbright=bright;
}


void graphicst::addst(const string &str_orig, justification just, int space)
{
  if (!str_orig.size())
    return;
  string str = str_orig;
  if (space)
    abbreviate_string_hackaroundmissingcode(str, space);
  if (just == not_truetype || !ttf_manager.ttf_active()) {
    int s;
    for(s=0;s<str.length()&&screenx<init.display.grid_x;s++)
      {
        if(screenx<0)
          {
            s-=screenx;
            screenx=0;
            if(s>=str.length())break;
          }
        
        addchar(str[s]);
      }
  } else {
    // Truetype
    if (str.size() > 2 && str[0] == ':' && str[1] == ' ')
      str[1] = '\t'; // EVIL HACK
    struct ttf_id id = {str, screenf, screenb, screenbright};
    ttfstr.push_back(id);
    // if (str.size() == 80) {
    //   cout << "(" << int(str[0]) << ") ";
    // }
    // cout << screeny << "," << str.size() << ":" << str;
    // if (just == justify_cont)
    //   cout << "|";
    // else
    //   cout << endl;
    if (just == justify_cont)
      return; // More later
    // This string is done. Time to render.
    ttf_details details = ttf_manager.get_handle(ttfstr, just);
    const int handle = details.handle;
    const int offset = details.offset;
    int width = details.width;
    const int ourx = screenx + offset;
    unsigned int * const s = ((unsigned int*)screen + ourx*dimy + screeny);
    if (s < (unsigned int*)screen_limit)
      s[0] = (((unsigned int)GRAPHICSTYPE_TTF) << 24) | handle;
    // Also set the other tiles this text covers, but don't write past the end.
    if (width + ourx >= dimx)
      width = dimx - ourx - 1;
    for (int x = 1; x < width; ++x)
      s[x * dimy] = (((unsigned int)GRAPHICSTYPE_TTFCONT) << 24) | handle;
    // Clean up, prepare for next string.
    screenx = ourx + width;
    ttfstr.clear();
  }
}