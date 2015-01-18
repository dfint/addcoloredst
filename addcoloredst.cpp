

void graphicst::addcoloredst(const char *str, const char *colorstr)
{
    const int slen = strlen(str);
    int s;
    for(s=0; s < slen && screenx < init.display.grid_x; s++)
    {
        if(screenx<0)
        {
            s-=screenx;
            screenx=0;
            if (s >= slen) break;
        }

        changecolor((colorstr[s] & 7),((colorstr[s] & 56))>>3,((colorstr[s] & 64))>>6);
        string someBuf = str[s];
        addst(someBuf);
    }
}

void graphicst::changecolor(short f,short b,char bright)
{
    screenf=f;
    screenb=b;
    screenbright=bright;
}
