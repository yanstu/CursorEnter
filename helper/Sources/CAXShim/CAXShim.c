#include "CAXShim.h"

AXError cax_post_enter_to_pid(pid_t pid) {
    AXUIElementRef application = AXUIElementCreateApplication(pid);
    if (application == NULL) {
        return kAXErrorFailure;
    }

    AXError down = AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode)36, true);
    AXError up = AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode)36, false);
    CFRelease(application);

    if (down != kAXErrorSuccess) {
        return down;
    }

    return up;
}
