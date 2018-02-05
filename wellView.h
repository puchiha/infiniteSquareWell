//
//  wellView.h
//  SquareWell_unreal
//
//  Created by Prakrit Shrestha on 2/25/13.
//
//

#import <Cocoa/Cocoa.h>
#define V(x) ((x < xLeft)? vLeft: ((x < xRight)? vCenter: vRight))
#define SQR(x) ((x) * (x))

const int xWidth = 512;

@interface wellView: NSView
{
    
    IBOutlet id energyText;
    IBOutlet id vLeftText;
    IBOutlet id vRightText;
    IBOutlet id vCenterText;
    IBOutlet id xRightText;
    IBOutlet id xLeftText;
    
    double psi[xWidth];
    double vLeft, vCenter, vRight, xLeft, xRight, energy, energyScale, psiScale;
    
    int nDxPerPixel;
    double dx;
    
    bool draggingEnergy, draggingVLeft, draggingVRight, draggingVCenter, draggingXLeft, draggingXRight;
    
    NSImage *myImage;
    NSRect imageRect;
    
    double psiSound;
}

-(void)awakeFromNib;
-(void)computePsi;
-(IBAction)reset:(id)sender;

@end
