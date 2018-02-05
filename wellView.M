//
//  wellView.m
//  SquareWell_unreal
//
//  Created by Prakrit Shrestha on 2/25/13.
//
//

#import "wellView.h"

@implementation wellView

- (id)initWithFrame:(NSRect)frame
{
    if (self)
    {
        vLeft = 0.0040;
        vCenter = 0.001;
        vRight = 0.0035;
        
        xLeft = 150.0;
        xRight = xWidth - xLeft;
        
        energy = 0.0030;
        energyScale = 1e5;
        psiScale = 6.7e1;
        
        nDxPerPixel = 10;
        dx = (double) 1.0 / nDxPerPixel;
        
        self = [super initWithFrame:frame];
        return self;
    }
    self = [super initWithFrame:frame];
    return self;
}

-(void)awakeFromNib
{
    myImage = [NSImage imageNamed:@"cat.png"];      //background cat
    imageRect = NSMakeRect(0, 0, 512, 512);
    
    [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:YES];
    [self addCursorRect:[self bounds] cursor:[NSCursor openHandCursor]];
    
    [self reset: self];
}

-(void)reset:(id)sender
{
    energy = 0.0030;
    
    vLeft = 0.0040;
    vCenter = 0.001;
    vRight = 0.0035;
    
    xLeft = 150.0;
    xRight = xWidth - xLeft;
    
    [energyText setDoubleValue:energy];     //update value on textField
    [vLeftText setDoubleValue:vLeft];
    [vRightText setDoubleValue:vRight];
    [vCenterText setDoubleValue:vCenter];
    [xRightText setDoubleValue:(xRight / energyScale)];
    [xLeftText setDoubleValue:(xLeft / energyScale)];
    
    [self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self computePsi];      //invoke computePsi
    
    [[NSColor blackColor]set];
    [NSBezierPath fillRect:dirtyRect];
    [myImage drawInRect:dirtyRect fromRect:imageRect operation:NSCompositeSourceIn    fraction:1.0];
    
    [[NSColor whiteColor]set];
    NSBezierPath *energyDraw = [NSBezierPath bezierPath];   //energy
    {
        [energyDraw setLineWidth: 3.0];
        [energyDraw moveToPoint:NSMakePoint(0, energy * energyScale)];
        [energyDraw lineToPoint:NSMakePoint(xWidth, energy * energyScale)];
    }
    [energyDraw stroke];
    
    [[NSColor yellowColor] set];
    NSBezierPath *potentialDraw = [NSBezierPath bezierPath];        //potential
    {
        [potentialDraw setLineWidth: 3.0];
        
        [potentialDraw moveToPoint:NSMakePoint(0, vLeft * energyScale)];
        [potentialDraw lineToPoint:NSMakePoint(xLeft, vLeft * energyScale)];
        [potentialDraw lineToPoint:NSMakePoint(xLeft, vCenter * energyScale)];
        [potentialDraw lineToPoint:NSMakePoint(xRight, vCenter * energyScale)];
        [potentialDraw lineToPoint:NSMakePoint(xRight, vRight * energyScale)];
        [potentialDraw lineToPoint:NSMakePoint(xWidth, vRight * energyScale)];
    }
    [potentialDraw stroke];
    
    [[NSColor blueColor] set];
    NSBezierPath *psiDraw = [NSBezierPath bezierPath];      //psi wave
    {
        [psiDraw setLineWidth: 3.0];
        
        [psiDraw moveToPoint:NSMakePoint(0, psi[0] * psiScale + energyScale * energy)];
        
        for (int i = 1; i < xWidth; i++)
        {
            [psiDraw lineToPoint:NSMakePoint(i, psi[i] * psiScale + energyScale * energy)];
        }
    }
    [psiDraw stroke];
    
}

-(void)computePsi
{
    double psi_, psi_dx, psi_2dx;
    double kappa;
    kappa = sqrt(vLeft - energy);
    double k = sqrt(energy - vLeft);
    
    if (energy <= vLeft)
    {
        double norm = exp(kappa * xLeft);
        psi_2dx = exp(-kappa * 2 * dx)/norm;
        psi_dx = exp(-kappa * dx)/norm;
        psi_ = exp(0)/norm;
    }
    else
    {
        double norm = sin(k * xLeft);
        psi_2dx = sin(-k * 2 * dx)/norm;
        psi_dx = sin(-k * dx)/norm;
        psi_ = sin(0)/norm;
        
    }
    
    double x = 0.0;
    
    for (int n = 0; n < xWidth; n++)
    {
        psi[n] = psi_;
        for (int n_ = 0; n_ < nDxPerPixel; n_++)
        {
            psi_ = (2 * psi_dx - psi_2dx - SQR(dx) * (energy - V(x - dx)) * psi_dx);    //schrodinger
            
            psi_2dx = psi_dx;
            psi_dx = psi_;
            x += dx;
        }
    }
}

/*****
 MOUSE DRAG
 *****/

-(void)mouseDown:(NSEvent *)theEvent
{
    NSPoint downInWindow = [theEvent locationInWindow];
    NSPoint downInView = [self convertPoint:downInWindow fromView:nil];
    
    static const short halfHeight = 4;  //for ease of grabbing
    
    NSRect energyRect = NSMakeRect(0, energy * energyScale - halfHeight, xWidth, 2 * halfHeight);   //construct rect for grabbing waves
    NSRect vLeftRect = NSMakeRect(0, vLeft * energyScale - halfHeight, xLeft, 2 * halfHeight);
    NSRect vRightRect = NSMakeRect(xRight, vRight * energyScale - halfHeight, xWidth, 2 * halfHeight);
    NSRect vCenterRect = NSMakeRect(xLeft, vCenter * energyScale - halfHeight, xRight, 2 * halfHeight);
    NSRect xLeftRect = NSMakeRect(xLeft - halfHeight, vCenter * energyScale, 2 * halfHeight, vLeft * energyScale);
    NSRect xRightRect = NSMakeRect(xRight - halfHeight, vCenter * energyScale, 2 * halfHeight, vRight * energyScale);
    
    draggingEnergy = [self mouse: downInView inRect:energyRect];    //check wave for grabbing
    draggingVLeft = [self mouse: downInView inRect:vLeftRect];
    draggingVRight = [self mouse: downInView inRect:vRightRect];
    draggingVCenter = [self mouse: downInView inRect:vCenterRect];
    draggingXLeft = [self mouse: downInView inRect:xLeftRect];
    draggingXRight = [self mouse: downInView inRect:xRightRect];
    
    if (draggingEnergy || draggingVLeft || draggingVRight || draggingVCenter || draggingXLeft || draggingXRight)
    {
        [[NSCursor closedHandCursor] set];
    }
    
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint downInWindow = [theEvent locationInWindow];
    NSPoint downInView = [self convertPoint:downInWindow fromView:nil];
    
    [[NSCursor closedHandCursor] set];
    
    static NSSound *crossingSound = [NSSound soundNamed: @"Purr.aiff"];
    
    if ((psiSound * psi[xWidth - 1]) < 0.0)     //sound for eigenvalue
    {
        [crossingSound play];
    }
    [self computePsi];
    
    psiSound = psi[xWidth - 1];
    
    /*Change value graphically*/
    if(draggingEnergy && downInView.y && downInView.y > 0 && downInView.y < 512)
    {
        energy = downInView.y / energyScale;
        [energyText setDoubleValue: energy];
        [self computePsi];
        [self setNeedsDisplay:YES];
        
    }
    
    else if(draggingVLeft && downInView.y && downInView.y > 0 && downInView.y < 512 )
    {
        vLeft = downInView.y / energyScale;
        [vLeftText setDoubleValue: vLeft];
        [self computePsi];
        [self setNeedsDisplay:YES];
    }
    else if(draggingVRight && downInView.y && downInView.y > 0 && downInView.y < 512 )
    {
        vRight = downInView.y / energyScale;
        [vRightText setDoubleValue: vRight];
        [self computePsi];
        [self setNeedsDisplay:YES];
    }
    else if(draggingVCenter && downInView.y && downInView.y > 0 && downInView.y < MIN((vLeft * energyScale), (vRight * energyScale)))
    {
        vCenter = downInView.y / energyScale;
        [vCenterText setDoubleValue: vCenter];
        [self computePsi];
        [self setNeedsDisplay:YES];
    }
    else if(draggingXLeft && downInView.x && downInView.x > 0 && downInView.x < xRight )
    {
        xLeft = downInView.x;
        [xLeftText setDoubleValue: xLeft];
        [self computePsi];
        [self setNeedsDisplay:YES];
    }
    else if(draggingXRight && downInView.x && downInView.x > xLeft && downInView.x < 512 )
    {
        xRight = downInView.x;
        [xRightText setDoubleValue: xRight];
        [self computePsi];
        [self setNeedsDisplay:YES];
    }
    
}

-(void)mouseUp:(NSEvent *)theEvent
{
    NSPoint downInWindow = [theEvent locationInWindow];
    NSPoint downInView = [self convertPoint:downInWindow fromView:nil];
    
    if(not [self mouse:downInView inRect:NSMakeRect(0, 0, 512, 512)])
    {
        [[NSCursor arrowCursor] set];
    }
    else
    {
        [[NSCursor openHandCursor] set];
    }
}

-(void)mouseExited:(NSEvent *)theEvent
{
    NSPoint downInWindow = [theEvent locationInWindow];
    NSPoint downInView = [self convertPoint:downInWindow
                                   fromView:nil];
    if(not [self mouse:downInView inRect:NSMakeRect(0,0, 512, 512)])    [[NSCursor arrowCursor] set];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    NSPoint downInWindow = [theEvent locationInWindow];
    NSPoint downInView = [self convertPoint:downInWindow
                                   fromView:nil];
    if([self mouse:downInView inRect:NSMakeRect(0,0, 512, 512)])    [[NSCursor openHandCursor]set];
    
}
@end
