//
//  HXGCell.m
//  Hex
//
//  Created by Chris Seez on 03/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGCell.h"

@implementation HXGCell

+ (id) cellWithWafer:(NSPoint *)w side:(double)s at:(NSPoint) p ID:(int)i andDetId:(int *) d {
    HXGCell * slf = [[HXGCell  alloc] init];
    
    [slf setUpWithWafer:w side:s at:p ID:i andDetId:d];
    
    return slf;
}

- (void) setUpWithWafer:(NSPoint *)w side:(double)s at:(NSPoint) p ID:(int)i andDetId:(int *) d {
    
    _irColor = 0;
    _ID = i;
    _iu = d[0];
    _iv = d[1];
    for(int i=0;i<6;i++) { waferPoints[i] = w[i];}
    _side = s;
    hftof = _side * sqrt(3.) * 0.5;
    _centre = p;
    waferside = waferPoints[2].y - waferPoints[1].y;
    _count = (int) (waferside/(2.*hftof) + 0.5);
    
    double xoff[6],yoff[6];
    xoff[0] = -_side*0.5; yoff[0] = - hftof;
    xoff[1] =  _side*0.5; yoff[1] = - hftof;
    xoff[2] =  _side;     yoff[2] = 0.0;
    xoff[3] =  _side*0.5; yoff[3] = hftof;
    xoff[4] = -_side*0.5; yoff[4] = hftof;
    xoff[5] = -_side;     yoff[5] = 0.0;

    _gridCell = [NSBezierPath bezierPath];
    [_gridCell moveToPoint:NSMakePoint(_centre.x+xoff[5],_centre.y+yoff[5])];
    for (int i=0; i<5; i++) {
        [_gridCell lineToPoint:NSMakePoint(_centre.x+xoff[i],_centre.y+yoff[i])];
    }
    [_gridCell closePath];
    _wholeCell = _gridCell;

    
    [self defineInsiders];

}

- (void) defineInsiders {
    
    _inside = NO;
    _whole = NO;
    _small = NO;
    _corner = NO;
    
    double r = sqrt((_centre.x)*(_centre.x) + (_centre.y)*(_centre.y));
    if(r > waferPoints[3].y) return; // not inside
    if(fabs(_centre.x) > waferPoints[1].x) return; // not inside [*] (see below)
    
    if(r < waferPoints[2].x-1.05*_side) {       // certainly inside
        _inside = YES;
        _whole = YES;
        _cellColor = [NSColor paleBlue]; // inside cell
        [self setTrigger];
        return;
    }
    
    // The distance from a point (m, n) to the line Ax + By + C = 0 is given by:
    // d=∣Am+Bn+C∣/sqrt(A*A + B*B)
    // (in the code below B=1, and mA is -A of the above formula - and equal to m of the formula y = mx+c)
    
    // first find the closest line
    
    int imin = -1;
    double dmin=9999.;
    for (int i=0;i<6;i++) {
        double d;
        if(i==1 || i==4) {
            d = waferPoints[i].x - _centre.x;
        } else {
            double mA = (waferPoints[i].y-waferPoints[(i+1)%6].y)/(waferPoints[i].x-waferPoints[(i+1)%6].x);
            double C  = - waferPoints[i].y + waferPoints[i].x*mA;
            d = (-mA*_centre.x + _centre.y + C)/sqrt(mA*mA + 1.);

        }
        if(fabs(d) < fabs(dmin)) {
            dmin = d;
            imin = i;
        }
    }
    
    if(imin != 1 && imin != 4 && dmin*_centre.y > 0.) return; // Just happens to be the way it is
    
    if(fabs(dmin) > 1.05*_side) {
        _inside = YES;
        _whole = YES;
        _wholeCell = _gridCell;
        _cellColor = [NSColor paleBlue]; // inside cell
        [self setTrigger];
        return;
    }
    
    _inside = YES;
    [self makeSpecialOn:imin];
    [self setTrigger];
    
}

- (void) makeSpecialOn:(int) i {
   
    double xoff[6],yoff[6];
    xoff[0] = -_side*0.5; yoff[0] = - hftof;
    xoff[1] =  _side*0.5; yoff[1] = - hftof;
    xoff[2] =  _side;     yoff[2] = 0.0;
    xoff[3] =  _side*0.5; yoff[3] = hftof;
    xoff[4] = -_side*0.5; yoff[4] = hftof;
    xoff[5] = -_side;     yoff[5] = 0.0;

    _edgeCell = [NSBezierPath bezierPath];
    if(i==0) {
        [_edgeCell moveToPoint:NSMakePoint(_centre.x+xoff[3],_centre.y+yoff[3])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[4],_centre.y+yoff[4])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[5],_centre.y+yoff[5])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x-0.25*_side,_centre.y-1.5*hftof)];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+1.25*_side,_centre.y-0.5*hftof)];
        [_edgeCell closePath];
    } else if(i==1) {
        _small = YES;
        if(waferPoints[2].y - _centre.y < _side) {
            _corner = YES;
            [_edgeCell moveToPoint:waferPoints[2]];
            [_edgeCell lineToPoint:NSMakePoint(_centre.x-0.25*_side,_centre.y+1.5*hftof)];
        } else [_edgeCell moveToPoint:NSMakePoint(_centre.x+xoff[4],_centre.y+yoff[4])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[5],_centre.y+yoff[5])];
        if(_centre.y - waferPoints[1].y < _side) {
            _corner = YES;
            [_edgeCell lineToPoint:NSMakePoint(_centre.x-0.25*_side,_centre.y-1.5*hftof)];
            [_edgeCell lineToPoint:waferPoints[1]];
        } else [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[0],_centre.y+yoff[0])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[1],_centre.y+yoff[1])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[3],_centre.y+yoff[3])];
        [_edgeCell closePath];
    } else if(i==2) {
        [_edgeCell moveToPoint:NSMakePoint(_centre.x+xoff[5],_centre.y+yoff[5])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[0],_centre.y+yoff[0])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[1],_centre.y+yoff[1])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+1.25*_side,_centre.y+0.5*hftof)];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x-0.25*_side,_centre.y+1.5*hftof)];
        [_edgeCell closePath];
    } else if(i==3) { //change and start at 1!
        _small = YES;
        [_edgeCell moveToPoint:NSMakePoint(_centre.x+xoff[1],_centre.y+yoff[1])];
        if(waferPoints[3].x - _centre.x  < _side) {
            _corner = YES;
            [_edgeCell lineToPoint:NSMakePoint(_centre.x+1.25*_side,_centre.y+0.5*hftof)];
            [_edgeCell lineToPoint:waferPoints[3]];
        } else [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[2],_centre.y+yoff[2])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[3],_centre.y+yoff[3])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[5],_centre.y+yoff[5])];
        if(_centre.x - waferPoints[4].x  < 1.1*_side) {
            _corner = YES;
            [_edgeCell lineToPoint:waferPoints[4]];
            [_edgeCell lineToPoint:NSMakePoint(_centre.x-_side,_centre.y-hftof)];
         } else [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[0],_centre.y+yoff[0])];
        [_edgeCell closePath];
    } else if(i==4) {
        [_edgeCell moveToPoint:NSMakePoint(_centre.x+xoff[1],_centre.y+yoff[1])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[2],_centre.y+yoff[2])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[3],_centre.y+yoff[3])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x-_side,_centre.y+hftof)];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x-_side,_centre.y-hftof)];
        [_edgeCell closePath];
    } else if(i==5) {
        _small = YES;
        [_edgeCell moveToPoint:NSMakePoint(_centre.x+xoff[3],_centre.y+yoff[3])];
        if(_centre.x - waferPoints[5].x < 1.1*_side) {
            _corner = YES;
            [_edgeCell lineToPoint:NSMakePoint(_centre.x-_side,_centre.y+hftof)];
            [_edgeCell lineToPoint:waferPoints[5]];
        } else [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[4],_centre.y+yoff[4])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[5],_centre.y+yoff[5])];
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[1],_centre.y+yoff[1])];
        if(waferPoints[0].x - _centre.x < _side) {
            _corner = YES;
            [_edgeCell lineToPoint:waferPoints[0]];
            [_edgeCell lineToPoint:NSMakePoint(_centre.x+1.25*_side,_centre.y-0.5*hftof)];
       }
        [_edgeCell lineToPoint:NSMakePoint(_centre.x+xoff[2],_centre.y+yoff[2])];
        [_edgeCell closePath];
    }
    
    if(!_small) _cellColor = [NSColor sageGreen];       // large side cell
    else if(_corner) _cellColor = [NSColor orchidPink]; // corner cell
    else _cellColor = [NSColor greyGreen];               // small side  cell
    
}

- (void) setTrigger {
    
    double dmin = 9999.;
    int imin;
    for (int i = 0; i<6; i+=2) {
        double d = sqrt((_centre.x-waferPoints[i].x)*(_centre.x-waferPoints[i].x) + (_centre.y-waferPoints[i].y)*(_centre.y-waferPoints[i].y));
        if(d < dmin) {
            dmin = d;
            imin = i;
        }
    }
    //NSLog(@"dmin = %.1f, imin = %d, _count = %d",dmin,imin,_count);
    imin = imin/2;
    if(_count == 8) {
        int it = _iu%2 + (_iv%2)*2;
        _keycell = (it == 0);
        if(imin == 0) {
            int iuoff[4] = {0,-1, 0,-1};
            int ivoff[4] = {0,-2,-1,-1};
            _iut = _iu + iuoff[it];
            _ivt = _iv + ivoff[it];
            _itc = ((_iut + _ivt)%6)/2;
        } else if(imin == 1) {
            int iuoff[4] = {0,-1, 0,-1};
            int ivoff[4] = {0, 0,-1,-1};
            _iut = _iu + iuoff[it];
            _ivt = _iv + ivoff[it];
            _itc = ((_iut + _ivt)%6)/2;
        } else if(imin == 2) {
            int iuoff[4] = {0,+1, 0,-1};
            int ivoff[4] = {0, 0,-1,-1};
            _iut = _iu + iuoff[it];
            _ivt = _iv + ivoff[it];
            _itc = ((_iut + _ivt)%6)/2;
        }
        _iut = _iut/2;
        _ivt = _ivt/2;
    } else {
        int it = _iu%3 + (_iv%3)*3;
        _keycell = (it == 0);
        if(imin == 0) {
            int iuoff[9] = {0,-1,-2, 0,-1,-2, 0,-1,-2};
            int ivoff[9] = {0,-3,-3,-1,-1,-4,-2,-2,-2};
            _iut = _iu + iuoff[it];
            _ivt = _iv + ivoff[it];
            _itc = ((_iut+_ivt)/3)%3;
        } else if(imin == 1) {
            int iuoff[9] = {0,-1,-2, 0,-1,-2, 0,-1,-2};
            int ivoff[9] = {0, 0, 0,-1,-1,-1,-2,-2,-2};
            _iut = _iu + iuoff[it];
            _ivt = _iv + ivoff[it];
            _itc = ((_iut+_ivt)/3)%3;
        } else if(imin == 2) {
            int iuoff[9] = {0,+2,+1, 0,-1,+1, 0,-1,-2};
            int ivoff[9] = {0, 0, 0,-1,-1,-1,-2,-2,-2};
            _iut = _iu + iuoff[it];
            _ivt = _iv + ivoff[it];
            _itc = ((_iut+_ivt)/3)%3;
        }
        _iut = _iut/3;
        _ivt = _ivt/3;
    }
}
@end
