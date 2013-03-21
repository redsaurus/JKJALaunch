//ATI_FSAA_SAMPLES is an old way of doing FSAA in ATI gfx cards
//which is not supported on Lion, so we use dyld_interpose to
//ignore the attempted calls as they lead to a crash. It might
//be best to eventually make this turn FSAA on in the standard
//OpenGL way instead.

#include <AGL/agl.h>
#include "dyld-interposing.h"

#define ATI_FSAA_SAMPLES 510

GLboolean aglFakeSetInteger(AGLContext ctx, GLenum pname, const GLint *params){
	if (pname == ATI_FSAA_SAMPLES){
		return GL_FALSE;
	}
	else{
		return aglSetInteger(ctx, pname, params);
	}
}

DYLD_INTERPOSE(aglFakeSetInteger,aglSetInteger);