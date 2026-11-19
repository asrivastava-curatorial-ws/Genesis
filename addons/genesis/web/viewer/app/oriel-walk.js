/* Oriel web walkthrough viewer 1.0.0-rc6 (MIT). Includes three.js and three-mesh-bvh (MIT): see LICENSES.txt */
var pd=0,yh=1,md=2;var Eo=1,gd=2,xr=3,pn=0,Ne=1,Pe=2,Ts=0,yr=1,Ro=2,vh=3,Mh=4,_d=5;var ws=100,xd=101,yd=102,vd=103,Md=104,Sd=200,bd=201,Td=202,wd=203,Sh=204,bh=205,Ad=206,Ed=207,Rd=208,Cd=209,Pd=210,Id=211,Ld=212,Nd=213,Dd=214,Na=0,Da=1,Ua=2,tr=3,Fa=4,Oa=5,Ba=6,za=7,Th=0,Ud=1,Fd=2,ri=0,Co=1,Po=2,Io=3,vr=4,wh=5,Lo=6,Ah=7,oh="attached",Od="detached",Eh=300,As=301,Mr=302,Sr=303,ic=304,Hn=1e3,xn=1001,er=1002,xe=1003,sc=1004;var Es=1005;var we=1006,br=1007;var Sn=1008;var an=1009,Rh=1010,Ch=1011,Tr=1012,rc=1013,Yn=1014,An=1015,cn=1016,oc=1017,ac=1018,Rs=1020,Ph=35902,Ih=35899,Lh=1021,Nh=1022,Fn=1023,bi=1026,Di=1027,cc=1028,lc=1029,$i=1030,hc=1031;var uc=1033,No=33776,Do=33777,Uo=33778,Fo=33779,fc=35840,dc=35841,pc=35842,mc=35843,gc=36196,_c=37492,xc=37496,yc=37488,vc=37489,Oo=37490,Mc=37491,Sc=37808,bc=37809,Tc=37810,wc=37811,Ac=37812,Ec=37813,Rc=37814,Cc=37815,Pc=37816,Ic=37817,Lc=37818,Nc=37819,Dc=37820,Uc=37821,Fc=36492,Oc=36494,Bc=36495,zc=36283,kc=36284,Bo=36285,Vc=36286;var ms=2300,gs=2301,Ia=2302,ah=2303,ch=2400,lh=2401,hh=2402,Bd=2500;var Dh=0,zo=1,wr=2,zd=3200;var Gc=0,kd=1,Ui="",ee="srgb",Ke="srgb-linear",no="linear",se="srgb";var La=7680;var Vd=519,Gd=512,Hd=513,Wd=514,Uh=515,Xd=516,qd=517,Fh=518,Oh=519,Bh=35044;var zh="300 es",Dn=2e3,nr=2001;function Om(s){for(let t=s.length-1;t>=0;--t)if(s[t]>=65535)return!0;return!1}function Bm(s){return ArrayBuffer.isView(s)&&!(s instanceof DataView)}function ir(s){return document.createElementNS("http://www.w3.org/1999/xhtml",s)}function Yd(){let s=ir("canvas");return s.style.display="block",s}var wf={},sr=null;function io(...s){let t="THREE."+s.shift();sr?sr("log",t,...s):console.log(t,...s)}function Kd(s){let t=s[0];if(typeof t=="string"&&t.startsWith("TSL:")){let e=s[1];e&&e.isStackTrace?s[0]+=" "+e.getLocation():s[1]='Stack trace not available. Enable "THREE.Node.captureStackTrace" to capture stack traces.'}return s}function Tt(...s){s=Kd(s);let t="THREE."+s.shift();if(sr)sr("warn",t,...s);else{let e=s[0];e&&e.isStackTrace?console.warn(e.getError(t)):console.warn(t,...s)}}function Dt(...s){s=Kd(s);let t="THREE."+s.shift();if(sr)sr("error",t,...s);else{let e=s[0];e&&e.isStackTrace?console.error(e.getError(t)):console.error(t,...s)}}function ps(...s){let t=s.join(" ");t in wf||(wf[t]=!0,Tt(...s))}function Zd(s,t,e){return new Promise(function(n,i){function r(){switch(s.clientWaitSync(t,s.SYNC_FLUSH_COMMANDS_BIT,0)){case s.WAIT_FAILED:i();break;case s.TIMEOUT_EXPIRED:setTimeout(r,e);break;default:n()}}setTimeout(r,e)})}var Jd={[Na]:Na,[Ua]:Ba,[Fa]:Fa,[tr]:Oa,[Da]:Da,[Ba]:Ua,[za]:za,[Oa]:tr},Qn=class{addEventListener(t,e){this._listeners===void 0&&(this._listeners={});let n=this._listeners;n[t]===void 0&&(n[t]=[]),n[t].indexOf(e)===-1&&n[t].push(e)}hasEventListener(t,e){let n=this._listeners;return n===void 0?!1:n[t]!==void 0&&n[t].indexOf(e)!==-1}removeEventListener(t,e){let n=this._listeners;if(n===void 0)return;let i=n[t];if(i!==void 0){let r=i.indexOf(e);r!==-1&&i.splice(r,1)}}dispatchEvent(t){let e=this._listeners;if(e===void 0)return;let n=e[t.type];if(n!==void 0){t.target=this;let i=n.slice(0);for(let r=0,o=i.length;r<o;r++)i[r].call(this,t);t.target=null}}},sn=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"],Af=1234567,to=Math.PI/180,_s=180/Math.PI;function oi(){let s=Math.random()*4294967295|0,t=Math.random()*4294967295|0,e=Math.random()*4294967295|0,n=Math.random()*4294967295|0;return(sn[s&255]+sn[s>>8&255]+sn[s>>16&255]+sn[s>>24&255]+"-"+sn[t&255]+sn[t>>8&255]+"-"+sn[t>>16&15|64]+sn[t>>24&255]+"-"+sn[e&63|128]+sn[e>>8&255]+"-"+sn[e>>16&255]+sn[e>>24&255]+sn[n&255]+sn[n>>8&255]+sn[n>>16&255]+sn[n>>24&255]).toLowerCase()}function kt(s,t,e){return Math.max(t,Math.min(e,s))}function kh(s,t){return(s%t+t)%t}function zm(s,t,e,n,i){return n+(s-t)*(i-n)/(e-t)}function km(s,t,e){return s!==t?(e-s)/(t-s):0}function eo(s,t,e){return(1-e)*s+e*t}function Vm(s,t,e,n){return eo(s,t,1-Math.exp(-e*n))}function Gm(s,t=1){return t-Math.abs(kh(s,t*2)-t)}function Hm(s,t,e){return s<=t?0:s>=e?1:(s=(s-t)/(e-t),s*s*(3-2*s))}function Wm(s,t,e){return s<=t?0:s>=e?1:(s=(s-t)/(e-t),s*s*s*(s*(s*6-15)+10))}function Xm(s,t){return s+Math.floor(Math.random()*(t-s+1))}function qm(s,t){return s+Math.random()*(t-s)}function Ym(s){return s*(.5-Math.random())}function Km(s){s!==void 0&&(Af=s);let t=Af+=1831565813;return t=Math.imul(t^t>>>15,t|1),t^=t+Math.imul(t^t>>>7,t|61),((t^t>>>14)>>>0)/4294967296}function Zm(s){return s*to}function Jm(s){return s*_s}function $m(s){return s>0&&Number.isInteger(s)&&2**Math.round(Math.log2(s))===s}function jm(s){return Math.pow(2,Math.ceil(Math.log(s)/Math.LN2))}function Vh(s){return Math.pow(2,Math.floor(Math.log(s)/Math.LN2))}function Qm(s,t,e,n,i){let r=Math.cos,o=Math.sin,a=r(e/2),c=o(e/2),l=r((t+n)/2),h=o((t+n)/2),f=r((t-n)/2),u=o((t-n)/2),d=r((n-t)/2),g=o((n-t)/2);switch(i){case"XYX":s.set(a*h,c*f,c*u,a*l);break;case"YZY":s.set(c*u,a*h,c*f,a*l);break;case"ZXZ":s.set(c*f,c*u,a*h,a*l);break;case"XZX":s.set(a*h,c*g,c*d,a*l);break;case"YXY":s.set(c*d,a*h,c*g,a*l);break;case"ZYZ":s.set(c*g,c*d,a*h,a*l);break;default:Tt("MathUtils: .setQuaternionFromProperEuler() encountered an unknown order: "+i)}}function Hc(s){switch(s.constructor){case Uint32Array:return 4294967295;case Uint16Array:return 65535;case Uint8Array:case Uint8ClampedArray:return 255;case Int32Array:return 2147483647;case Int16Array:return 32767;case Int8Array:return 127;default:return}}function Gh(s,t){if(t.constructor===Float32Array)return s;let e=Hc(t);if(e===void 0)throw new Error("THREE.MathUtils: Invalid component type.");return Math.max(s/e,-1)}function Hh(s,t){if(t.constructor===Float32Array)return s;let e=Hc(t);if(e===void 0)throw new Error("THREE.MathUtils: Invalid component type.");return Math.round(s*e)}var me={DEG2RAD:to,RAD2DEG:_s,generateUUID:oi,clamp:kt,euclideanModulo:kh,mapLinear:zm,inverseLerp:km,lerp:eo,damp:Vm,pingpong:Gm,smoothstep:Hm,smootherstep:Wm,randInt:Xm,randFloat:qm,randFloatSpread:Ym,seededRandom:Km,degToRad:Zm,radToDeg:Jm,isPowerOfTwo:$m,ceilPowerOfTwo:jm,floorPowerOfTwo:Vh,setQuaternionFromProperEuler:Qm,normalize:Hh,denormalize:Gh},Kh=class Kh{constructor(t=0,e=0){this.x=t,this.y=e}get width(){return this.x}set width(t){this.x=t}get height(){return this.y}set height(t){this.y=t}set(t,e){return this.x=t,this.y=e,this}setScalar(t){return this.x=t,this.y=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;default:throw new Error("THREE.Vector2: index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;default:throw new Error("THREE.Vector2: index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y)}copy(t){return this.x=t.x,this.y=t.y,this}add(t){return this.x+=t.x,this.y+=t.y,this}addScalar(t){return this.x+=t,this.y+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this}subScalar(t){return this.x-=t,this.y-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this}multiply(t){return this.x*=t.x,this.y*=t.y,this}multiplyScalar(t){return this.x*=t,this.y*=t,this}divide(t){return this.x/=t.x,this.y/=t.y,this}divideScalar(t){return this.multiplyScalar(1/t)}applyMatrix3(t){let e=this.x,n=this.y,i=t.elements;return this.x=i[0]*e+i[3]*n+i[6],this.y=i[1]*e+i[4]*n+i[7],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this}clamp(t,e){return this.x=kt(this.x,t.x,e.x),this.y=kt(this.y,t.y,e.y),this}clampScalar(t,e){return this.x=kt(this.x,t,e),this.y=kt(this.y,t,e),this}clampLength(t,e){let n=this.length();return this.divideScalar(n||1).multiplyScalar(kt(n,t,e))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(t){return this.x*t.x+this.y*t.y}cross(t){return this.x*t.y-this.y*t.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(t){let e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;let n=this.dot(t)/e;return Math.acos(kt(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){let e=this.x-t.x,n=this.y-t.y;return e*e+n*n}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this}equals(t){return t.x===this.x&&t.y===this.y}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this}rotateAround(t,e){let n=Math.cos(e),i=Math.sin(e),r=this.x-t.x,o=this.y-t.y;return this.x=r*n-o*i+t.x,this.y=r*i+o*n+t.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}};Kh.prototype.isVector2=!0;var At=Kh,wn=class{constructor(t=0,e=0,n=0,i=1){this.isQuaternion=!0,this._x=t,this._y=e,this._z=n,this._w=i}static slerpFlat(t,e,n,i,r,o,a){let c=n[i+0],l=n[i+1],h=n[i+2],f=n[i+3],u=r[o+0],d=r[o+1],g=r[o+2],v=r[o+3];if(f!==v||c!==u||l!==d||h!==g){let m=c*u+l*d+h*g+f*v;m<0&&(u=-u,d=-d,g=-g,v=-v,m=-m);let p=1-a;if(m<.9995){let x=Math.acos(m),M=Math.sin(x);p=Math.sin(p*x)/M,a=Math.sin(a*x)/M,c=c*p+u*a,l=l*p+d*a,h=h*p+g*a,f=f*p+v*a}else{c=c*p+u*a,l=l*p+d*a,h=h*p+g*a,f=f*p+v*a;let x=1/Math.sqrt(c*c+l*l+h*h+f*f);c*=x,l*=x,h*=x,f*=x}}t[e]=c,t[e+1]=l,t[e+2]=h,t[e+3]=f}static multiplyQuaternionsFlat(t,e,n,i,r,o){let a=n[i],c=n[i+1],l=n[i+2],h=n[i+3],f=r[o],u=r[o+1],d=r[o+2],g=r[o+3];return t[e]=a*g+h*f+c*d-l*u,t[e+1]=c*g+h*u+l*f-a*d,t[e+2]=l*g+h*d+a*u-c*f,t[e+3]=h*g-a*f-c*u-l*d,t}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get w(){return this._w}set w(t){this._w=t,this._onChangeCallback()}set(t,e,n,i){return this._x=t,this._y=e,this._z=n,this._w=i,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(t){return this._x=t.x,this._y=t.y,this._z=t.z,this._w=t.w,this._onChangeCallback(),this}setFromEuler(t,e=!0){let n=t._x,i=t._y,r=t._z,o=t._order,a=Math.cos,c=Math.sin,l=a(n/2),h=a(i/2),f=a(r/2),u=c(n/2),d=c(i/2),g=c(r/2);switch(o){case"XYZ":this._x=u*h*f+l*d*g,this._y=l*d*f-u*h*g,this._z=l*h*g+u*d*f,this._w=l*h*f-u*d*g;break;case"YXZ":this._x=u*h*f+l*d*g,this._y=l*d*f-u*h*g,this._z=l*h*g-u*d*f,this._w=l*h*f+u*d*g;break;case"ZXY":this._x=u*h*f-l*d*g,this._y=l*d*f+u*h*g,this._z=l*h*g+u*d*f,this._w=l*h*f-u*d*g;break;case"ZYX":this._x=u*h*f-l*d*g,this._y=l*d*f+u*h*g,this._z=l*h*g-u*d*f,this._w=l*h*f+u*d*g;break;case"YZX":this._x=u*h*f+l*d*g,this._y=l*d*f+u*h*g,this._z=l*h*g-u*d*f,this._w=l*h*f-u*d*g;break;case"XZY":this._x=u*h*f-l*d*g,this._y=l*d*f-u*h*g,this._z=l*h*g+u*d*f,this._w=l*h*f+u*d*g;break;default:Tt("Quaternion: .setFromEuler() encountered an unknown order: "+o)}return e===!0&&this._onChangeCallback(),this}setFromAxisAngle(t,e){let n=e/2,i=Math.sin(n);return this._x=t.x*i,this._y=t.y*i,this._z=t.z*i,this._w=Math.cos(n),this._onChangeCallback(),this}setFromRotationMatrix(t){let e=t.elements,n=e[0],i=e[4],r=e[8],o=e[1],a=e[5],c=e[9],l=e[2],h=e[6],f=e[10],u=n+a+f;if(u>0){let d=.5/Math.sqrt(u+1);this._w=.25/d,this._x=(h-c)*d,this._y=(r-l)*d,this._z=(o-i)*d}else if(n>a&&n>f){let d=2*Math.sqrt(1+n-a-f);this._w=(h-c)/d,this._x=.25*d,this._y=(i+o)/d,this._z=(r+l)/d}else if(a>f){let d=2*Math.sqrt(1+a-n-f);this._w=(r-l)/d,this._x=(i+o)/d,this._y=.25*d,this._z=(c+h)/d}else{let d=2*Math.sqrt(1+f-n-a);this._w=(o-i)/d,this._x=(r+l)/d,this._y=(c+h)/d,this._z=.25*d}return this._onChangeCallback(),this}setFromUnitVectors(t,e){let n=t.dot(e)+1;return n<1e-8?(n=0,Math.abs(t.x)>Math.abs(t.z)?(this._x=-t.y,this._y=t.x,this._z=0,this._w=n):(this._x=0,this._y=-t.z,this._z=t.y,this._w=n)):(this._x=t.y*e.z-t.z*e.y,this._y=t.z*e.x-t.x*e.z,this._z=t.x*e.y-t.y*e.x,this._w=n),this.normalize()}angleTo(t){return 2*Math.acos(Math.abs(kt(this.dot(t),-1,1)))}rotateTowards(t,e){let n=this.angleTo(t);if(n===0)return this;let i=Math.min(1,e/n);return this.slerp(t,i),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(t){return this._x*t._x+this._y*t._y+this._z*t._z+this._w*t._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let t=this.length();return t===0?(this._x=0,this._y=0,this._z=0,this._w=1):(t=1/t,this._x=this._x*t,this._y=this._y*t,this._z=this._z*t,this._w=this._w*t),this._onChangeCallback(),this}multiply(t){return this.multiplyQuaternions(this,t)}premultiply(t){return this.multiplyQuaternions(t,this)}multiplyQuaternions(t,e){let n=t._x,i=t._y,r=t._z,o=t._w,a=e._x,c=e._y,l=e._z,h=e._w;return this._x=n*h+o*a+i*l-r*c,this._y=i*h+o*c+r*a-n*l,this._z=r*h+o*l+n*c-i*a,this._w=o*h-n*a-i*c-r*l,this._onChangeCallback(),this}slerp(t,e){let n=t._x,i=t._y,r=t._z,o=t._w,a=this.dot(t);a<0&&(n=-n,i=-i,r=-r,o=-o,a=-a);let c=1-e;if(a<.9995){let l=Math.acos(a),h=Math.sin(l);c=Math.sin(c*l)/h,e=Math.sin(e*l)/h,this._x=this._x*c+n*e,this._y=this._y*c+i*e,this._z=this._z*c+r*e,this._w=this._w*c+o*e,this._onChangeCallback()}else this._x=this._x*c+n*e,this._y=this._y*c+i*e,this._z=this._z*c+r*e,this._w=this._w*c+o*e,this.normalize();return this}slerpQuaternions(t,e,n){return this.copy(t).slerp(e,n)}random(){let t=2*Math.PI*Math.random(),e=2*Math.PI*Math.random(),n=Math.random(),i=Math.sqrt(1-n),r=Math.sqrt(n);return this.set(i*Math.sin(t),i*Math.cos(t),r*Math.sin(e),r*Math.cos(e))}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._w===this._w}fromArray(t,e=0){return this._x=t[e],this._y=t[e+1],this._z=t[e+2],this._w=t[e+3],this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._w,t}fromBufferAttribute(t,e){return this._x=t.getX(e),this._y=t.getY(e),this._z=t.getZ(e),this._w=t.getW(e),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}},Zh=class Zh{constructor(t=0,e=0,n=0){this.x=t,this.y=e,this.z=n}set(t,e,n){return n===void 0&&(n=this.z),this.x=t,this.y=e,this.z=n,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;default:throw new Error("THREE.Vector3: index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("THREE.Vector3: index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this}multiplyVectors(t,e){return this.x=t.x*e.x,this.y=t.y*e.y,this.z=t.z*e.z,this}applyEuler(t){return this.applyQuaternion(Ef.setFromEuler(t))}applyAxisAngle(t,e){return this.applyQuaternion(Ef.setFromAxisAngle(t,e))}applyMatrix3(t){let e=this.x,n=this.y,i=this.z,r=t.elements;return this.x=r[0]*e+r[3]*n+r[6]*i,this.y=r[1]*e+r[4]*n+r[7]*i,this.z=r[2]*e+r[5]*n+r[8]*i,this}applyNormalMatrix(t){return this.applyMatrix3(t).normalize()}applyMatrix4(t){let e=this.x,n=this.y,i=this.z,r=t.elements,o=1/(r[3]*e+r[7]*n+r[11]*i+r[15]);return this.x=(r[0]*e+r[4]*n+r[8]*i+r[12])*o,this.y=(r[1]*e+r[5]*n+r[9]*i+r[13])*o,this.z=(r[2]*e+r[6]*n+r[10]*i+r[14])*o,this}applyQuaternion(t){let e=this.x,n=this.y,i=this.z,r=t.x,o=t.y,a=t.z,c=t.w,l=2*(o*i-a*n),h=2*(a*e-r*i),f=2*(r*n-o*e);return this.x=e+c*l+o*f-a*h,this.y=n+c*h+a*l-r*f,this.z=i+c*f+r*h-o*l,this}project(t){return this.applyMatrix4(t.matrixWorldInverse).applyMatrix4(t.projectionMatrix)}unproject(t){return this.applyMatrix4(t.projectionMatrixInverse).applyMatrix4(t.matrixWorld)}transformDirection(t){let e=this.x,n=this.y,i=this.z,r=t.elements;return this.x=r[0]*e+r[4]*n+r[8]*i,this.y=r[1]*e+r[5]*n+r[9]*i,this.z=r[2]*e+r[6]*n+r[10]*i,this.normalize()}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this}divideScalar(t){return this.multiplyScalar(1/t)}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this}clamp(t,e){return this.x=kt(this.x,t.x,e.x),this.y=kt(this.y,t.y,e.y),this.z=kt(this.z,t.z,e.z),this}clampScalar(t,e){return this.x=kt(this.x,t,e),this.y=kt(this.y,t,e),this.z=kt(this.z,t,e),this}clampLength(t,e){let n=this.length();return this.divideScalar(n||1).multiplyScalar(kt(n,t,e))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this}cross(t){return this.crossVectors(this,t)}crossVectors(t,e){let n=t.x,i=t.y,r=t.z,o=e.x,a=e.y,c=e.z;return this.x=i*c-r*a,this.y=r*o-n*c,this.z=n*a-i*o,this}projectOnVector(t){let e=t.lengthSq();if(e===0)return this.set(0,0,0);let n=t.dot(this)/e;return this.copy(t).multiplyScalar(n)}projectOnPlane(t){return Ul.copy(this).projectOnVector(t),this.sub(Ul)}reflect(t){return this.sub(Ul.copy(t).multiplyScalar(2*this.dot(t)))}angleTo(t){let e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;let n=this.dot(t)/e;return Math.acos(kt(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){let e=this.x-t.x,n=this.y-t.y,i=this.z-t.z;return e*e+n*n+i*i}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)+Math.abs(this.z-t.z)}setFromSpherical(t){return this.setFromSphericalCoords(t.radius,t.phi,t.theta)}setFromSphericalCoords(t,e,n){let i=Math.sin(e)*t;return this.x=i*Math.sin(n),this.y=Math.cos(e)*t,this.z=i*Math.cos(n),this}setFromCylindrical(t){return this.setFromCylindricalCoords(t.radius,t.theta,t.y)}setFromCylindricalCoords(t,e,n){return this.x=t*Math.sin(e),this.y=n,this.z=t*Math.cos(e),this}setFromMatrixPosition(t){let e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this}setFromMatrixScale(t){let e=this.setFromMatrixColumn(t,0).length(),n=this.setFromMatrixColumn(t,1).length(),i=this.setFromMatrixColumn(t,2).length();return this.x=e,this.y=n,this.z=i,this}setFromMatrixColumn(t,e){return this.fromArray(t.elements,e*4)}setFromMatrix3Column(t,e){return this.fromArray(t.elements,e*3)}setFromEuler(t){return this.x=t._x,this.y=t._y,this.z=t._z,this}setFromColor(t){return this.x=t.r,this.y=t.g,this.z=t.b,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){let t=Math.random()*Math.PI*2,e=Math.random()*2-1,n=Math.sqrt(1-e*e);return this.x=n*Math.cos(t),this.y=e,this.z=n*Math.sin(t),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}};Zh.prototype.isVector3=!0;var R=Zh,Ul=new R,Ef=new wn,Jh=class Jh{constructor(t,e,n,i,r,o,a,c,l){this.elements=[1,0,0,0,1,0,0,0,1],t!==void 0&&this.set(t,e,n,i,r,o,a,c,l)}set(t,e,n,i,r,o,a,c,l){let h=this.elements;return h[0]=t,h[1]=i,h[2]=a,h[3]=e,h[4]=r,h[5]=c,h[6]=n,h[7]=o,h[8]=l,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(t){let e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],this}extractBasis(t,e,n){return t.setFromMatrix3Column(this,0),e.setFromMatrix3Column(this,1),n.setFromMatrix3Column(this,2),this}setFromMatrix4(t){let e=t.elements;return this.set(e[0],e[4],e[8],e[1],e[5],e[9],e[2],e[6],e[10]),this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){let n=t.elements,i=e.elements,r=this.elements,o=n[0],a=n[3],c=n[6],l=n[1],h=n[4],f=n[7],u=n[2],d=n[5],g=n[8],v=i[0],m=i[3],p=i[6],x=i[1],M=i[4],y=i[7],S=i[2],T=i[5],_=i[8];return r[0]=o*v+a*x+c*S,r[3]=o*m+a*M+c*T,r[6]=o*p+a*y+c*_,r[1]=l*v+h*x+f*S,r[4]=l*m+h*M+f*T,r[7]=l*p+h*y+f*_,r[2]=u*v+d*x+g*S,r[5]=u*m+d*M+g*T,r[8]=u*p+d*y+g*_,this}multiplyScalar(t){let e=this.elements;return e[0]*=t,e[3]*=t,e[6]*=t,e[1]*=t,e[4]*=t,e[7]*=t,e[2]*=t,e[5]*=t,e[8]*=t,this}determinant(){let t=this.elements,e=t[0],n=t[1],i=t[2],r=t[3],o=t[4],a=t[5],c=t[6],l=t[7],h=t[8];return e*o*h-e*a*l-n*r*h+n*a*c+i*r*l-i*o*c}invert(){let t=this.elements,e=t[0],n=t[1],i=t[2],r=t[3],o=t[4],a=t[5],c=t[6],l=t[7],h=t[8],f=h*o-a*l,u=a*c-h*r,d=l*r-o*c,g=e*f+n*u+i*d;if(g===0)return this.set(0,0,0,0,0,0,0,0,0);let v=1/g;return t[0]=f*v,t[1]=(i*l-h*n)*v,t[2]=(a*n-i*o)*v,t[3]=u*v,t[4]=(h*e-i*c)*v,t[5]=(i*r-a*e)*v,t[6]=d*v,t[7]=(n*c-l*e)*v,t[8]=(o*e-n*r)*v,this}transpose(){let t,e=this.elements;return t=e[1],e[1]=e[3],e[3]=t,t=e[2],e[2]=e[6],e[6]=t,t=e[5],e[5]=e[7],e[7]=t,this}getNormalMatrix(t){return this.setFromMatrix4(t).invert().transpose()}transposeIntoArray(t){let e=this.elements;return t[0]=e[0],t[1]=e[3],t[2]=e[6],t[3]=e[1],t[4]=e[4],t[5]=e[7],t[6]=e[2],t[7]=e[5],t[8]=e[8],this}setUvTransform(t,e,n,i,r,o,a){let c=Math.cos(r),l=Math.sin(r);return this.set(n*c,n*l,-n*(c*o+l*a)+o+t,-i*l,i*c,-i*(-l*o+c*a)+a+e,0,0,1),this}scale(t,e){return ps("Matrix3: .scale() is deprecated. Use .makeScale() instead."),this.premultiply(Fl.makeScale(t,e)),this}rotate(t){return ps("Matrix3: .rotate() is deprecated. Use .makeRotation() instead."),this.premultiply(Fl.makeRotation(-t)),this}translate(t,e){return ps("Matrix3: .translate() is deprecated. Use .makeTranslation() instead."),this.premultiply(Fl.makeTranslation(t,e)),this}makeTranslation(t,e){return t.isVector2?this.set(1,0,t.x,0,1,t.y,0,0,1):this.set(1,0,t,0,1,e,0,0,1),this}makeRotation(t){let e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,n,e,0,0,0,1),this}makeScale(t,e){return this.set(t,0,0,0,e,0,0,0,1),this}equals(t){let e=this.elements,n=t.elements;for(let i=0;i<9;i++)if(e[i]!==n[i])return!1;return!0}fromArray(t,e=0){for(let n=0;n<9;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){let n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t}clone(){return new this.constructor().fromArray(this.elements)}};Jh.prototype.isMatrix3=!0;var Ft=Jh,Fl=new Ft,Rf=new Ft().set(.4123908,.3575843,.1804808,.212639,.7151687,.0721923,.0193308,.1191948,.9505322),Cf=new Ft().set(3.2409699,-1.5373832,-.4986108,-.9692436,1.8759675,.0415551,.0556301,-.203977,1.0569715);function tg(){let s={enabled:!0,workingColorSpace:Ke,spaces:{},convert:function(i,r,o){return this.enabled===!1||r===o||!r||!o||(this.spaces[r].transfer===se&&(i.r=Si(i.r),i.g=Si(i.g),i.b=Si(i.b)),this.spaces[r].primaries!==this.spaces[o].primaries&&(i.applyMatrix3(this.spaces[r].toXYZ),i.applyMatrix3(this.spaces[o].fromXYZ)),this.spaces[o].transfer===se&&(i.r=Qs(i.r),i.g=Qs(i.g),i.b=Qs(i.b))),i},workingToColorSpace:function(i,r){return this.convert(i,this.workingColorSpace,r)},colorSpaceToWorking:function(i,r){return this.convert(i,r,this.workingColorSpace)},getPrimaries:function(i){return this.spaces[i].primaries},getTransfer:function(i){return i===Ui?no:this.spaces[i].transfer},getToneMappingMode:function(i){return this.spaces[i].outputColorSpaceConfig.toneMappingMode||"standard"},getLuminanceCoefficients:function(i,r=this.workingColorSpace){return i.fromArray(this.spaces[r].luminanceCoefficients)},define:function(i){Object.assign(this.spaces,i)},_getMatrix:function(i,r,o){return i.copy(this.spaces[o].fromXYZ).multiply(this.spaces[r].toXYZ)},_getDrawingBufferColorSpace:function(i){return this.spaces[i].outputColorSpaceConfig.drawingBufferColorSpace},_getUnpackColorSpace:function(i=this.workingColorSpace){return this.spaces[i].workingColorSpaceConfig.unpackColorSpace}},t=[.64,.33,.3,.6,.15,.06],e=[.2126,.7152,.0722],n=[.3127,.329];return s.define({[Ke]:{primaries:t,whitePoint:n,transfer:no,toXYZ:Rf,fromXYZ:Cf,luminanceCoefficients:e,workingColorSpaceConfig:{unpackColorSpace:ee},outputColorSpaceConfig:{drawingBufferColorSpace:ee}},[ee]:{primaries:t,whitePoint:n,transfer:se,toXYZ:Rf,fromXYZ:Cf,luminanceCoefficients:e,outputColorSpaceConfig:{drawingBufferColorSpace:ee}}}),s}var Ht=tg();function Si(s){return s<.04045?s*.0773993808:Math.pow(s*.9478672986+.0521327014,2.4)}function Qs(s){return s<.0031308?s*12.92:1.055*Math.pow(s,.41666)-.055}var Os,ka=class{static getDataURL(t,e="image/png"){if(/^data:/i.test(t.src)||typeof HTMLCanvasElement>"u")return t.src;let n;if(t instanceof HTMLCanvasElement)n=t;else{Os===void 0&&(Os=ir("canvas")),Os.width=t.width,Os.height=t.height;let i=Os.getContext("2d");t instanceof ImageData?i.putImageData(t,0,0):i.drawImage(t,0,0,t.width,t.height),n=Os}return n.toDataURL(e)}static sRGBToLinear(t){if(typeof HTMLImageElement<"u"&&t instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&t instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&t instanceof ImageBitmap){let e=ir("canvas");e.width=t.width,e.height=t.height;let n=e.getContext("2d");n.drawImage(t,0,0,t.width,t.height);let i=n.getImageData(0,0,t.width,t.height),r=i.data;for(let o=0;o<r.length;o++)r[o]=Si(r[o]/255)*255;return n.putImageData(i,0,0),e}else if(t.data){let e=t.data.slice(0);for(let n=0;n<e.length;n++)e instanceof Uint8Array||e instanceof Uint8ClampedArray?e[n]=Math.floor(Si(e[n]/255)*255):e[n]=Si(e[n]);return{data:e,width:t.width,height:t.height}}else return Tt("ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),t}},eg=0,rr=class{constructor(t=null){this.isTextureSource=!0,Object.defineProperty(this,"id",{value:eg++}),this.uuid=oi(),this.data=t,this.dataReady=!0,this.version=0}getSize(t){let e=this.data;return typeof HTMLVideoElement<"u"&&e instanceof HTMLVideoElement?t.set(e.videoWidth,e.videoHeight,0):typeof VideoFrame<"u"&&e instanceof VideoFrame?t.set(e.displayWidth,e.displayHeight,0):e!==null?t.set(e.width||0,e.height||0,e.depth||0):t.set(0,0,0),t}set needsUpdate(t){t===!0&&this.version++}toJSON(t){let e=t===void 0||typeof t=="string";if(!e&&t.images[this.uuid]!==void 0)return t.images[this.uuid];let n={uuid:this.uuid,url:""},i=this.data;if(i!==null){let r;if(Array.isArray(i)){r=[];for(let o=0,a=i.length;o<a;o++)i[o].isDataTexture?r.push(Ol(i[o].image)):r.push(Ol(i[o]))}else r=Ol(i);n.url=r}return e||(t.images[this.uuid]=n),n}};function Ol(s){return typeof HTMLImageElement<"u"&&s instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&s instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&s instanceof ImageBitmap?ka.getDataURL(s):s.data?{data:Array.from(s.data),width:s.width,height:s.height,type:s.data.constructor.name}:(Tt("Texture: Unable to serialize Texture."),{})}var ng=0,Bl=new R,ke=class s extends Qn{constructor(t=s.DEFAULT_IMAGE,e=s.DEFAULT_MAPPING,n=xn,i=xn,r=we,o=Sn,a=Fn,c=an,l=s.DEFAULT_ANISOTROPY,h=Ui){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:ng++}),this.uuid=oi(),this.name="",this.source=new rr(t),this.mipmaps=[],this.mapping=e,this.channel=0,this.wrapS=n,this.wrapT=i,this.magFilter=r,this.minFilter=o,this.anisotropy=l,this.format=a,this.internalFormat=null,this.type=c,this.offset=new At(0,0),this.repeat=new At(1,1),this.center=new At(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new Ft,this.generateMipmaps=!0,this.mipmapsAutoUpdate=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,this.colorSpace=h,this.userData={},this.updateRanges=[],this.version=0,this.onUpdate=null,this.renderTarget=null,this.isRenderTargetTexture=!1,this.isArrayTexture=!!(t&&t.depth&&t.depth>1),this.pmremVersion=0,this.isPMREMTexture=!1,this.normalized=!1}get width(){return this.source.getSize(Bl).x}get height(){return this.source.getSize(Bl).y}get depth(){return this.source.getSize(Bl).z}get image(){return this.source.data}set image(t){this.source.data=t}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}clone(){return new this.constructor().copy(this)}copy(t){return this.name=t.name,this.source=t.source,this.mipmaps=t.mipmaps.slice(0),this.mapping=t.mapping,this.channel=t.channel,this.wrapS=t.wrapS,this.wrapT=t.wrapT,this.magFilter=t.magFilter,this.minFilter=t.minFilter,this.anisotropy=t.anisotropy,this.format=t.format,this.internalFormat=t.internalFormat,this.type=t.type,this.normalized=t.normalized,this.offset.copy(t.offset),this.repeat.copy(t.repeat),this.center.copy(t.center),this.rotation=t.rotation,this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrix.copy(t.matrix),this.generateMipmaps=t.generateMipmaps,this.mipmapsAutoUpdate=t.mipmapsAutoUpdate,this.premultiplyAlpha=t.premultiplyAlpha,this.flipY=t.flipY,this.unpackAlignment=t.unpackAlignment,this.colorSpace=t.colorSpace,this.renderTarget=t.renderTarget,this.isRenderTargetTexture=t.isRenderTargetTexture,this.isPMREMTexture=t.isPMREMTexture,this.isArrayTexture=t.isArrayTexture,this.userData=JSON.parse(JSON.stringify(t.userData)),this.needsUpdate=!0,this}setValues(t){for(let e in t){let n=t[e];if(n===void 0){Tt(`Texture.setValues(): parameter '${e}' has value of undefined.`);continue}let i=this[e];if(i===void 0){Tt(`Texture.setValues(): property '${e}' does not exist.`);continue}i&&n&&i.isVector2&&n.isVector2||i&&n&&i.isVector3&&n.isVector3||i&&n&&i.isMatrix3&&n.isMatrix3?i.copy(n):this[e]=n}}toJSON(t){let e=t===void 0||typeof t=="string";if(!e&&t.textures[this.uuid]!==void 0)return t.textures[this.uuid];let n={metadata:{version:4.7,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(t).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,normalized:this.normalized,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,mipmapsAutoUpdate:this.mipmapsAutoUpdate,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(n.userData=this.userData),e||(t.textures[this.uuid]=n),n}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(t){if(this.mapping!==Eh)return t;if(t.applyMatrix3(this.matrix),t.x<0||t.x>1)switch(this.wrapS){case Hn:t.x=t.x-Math.floor(t.x);break;case xn:t.x=t.x<0?0:1;break;case er:Math.abs(Math.floor(t.x)%2)===1?t.x=Math.ceil(t.x)-t.x:t.x=t.x-Math.floor(t.x);break}if(t.y<0||t.y>1)switch(this.wrapT){case Hn:t.y=t.y-Math.floor(t.y);break;case xn:t.y=t.y<0?0:1;break;case er:Math.abs(Math.floor(t.y)%2)===1?t.y=Math.ceil(t.y)-t.y:t.y=t.y-Math.floor(t.y);break}return this.flipY&&(t.y=1-t.y),t}set needsUpdate(t){t===!0&&(this.version++,this.source.needsUpdate=!0)}set needsPMREMUpdate(t){t===!0&&this.pmremVersion++}};ke.DEFAULT_IMAGE=null;ke.DEFAULT_MAPPING=Eh;ke.DEFAULT_ANISOTROPY=1;var $h=class $h{constructor(t=0,e=0,n=0,i=1){this.x=t,this.y=e,this.z=n,this.w=i}get width(){return this.z}set width(t){this.z=t}get height(){return this.w}set height(t){this.w=t}set(t,e,n,i){return this.x=t,this.y=e,this.z=n,this.w=i,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this.w=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setW(t){return this.w=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;case 3:this.w=e;break;default:throw new Error("THREE.Vector4: index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("THREE.Vector4: index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this.w=t.w!==void 0?t.w:1,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this.w+=t.w,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this.w+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this.w=t.w+e.w,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this.w+=t.w*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this.w-=t.w,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this.w-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this.w=t.w-e.w,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this.w*=t.w,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this.w*=t,this}applyMatrix4(t){let e=this.x,n=this.y,i=this.z,r=this.w,o=t.elements;return this.x=o[0]*e+o[4]*n+o[8]*i+o[12]*r,this.y=o[1]*e+o[5]*n+o[9]*i+o[13]*r,this.z=o[2]*e+o[6]*n+o[10]*i+o[14]*r,this.w=o[3]*e+o[7]*n+o[11]*i+o[15]*r,this}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this.w/=t.w,this}divideScalar(t){return this.multiplyScalar(1/t)}setAxisAngleFromQuaternion(t){this.w=2*Math.acos(t.w);let e=Math.sqrt(1-t.w*t.w);return e<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=t.x/e,this.y=t.y/e,this.z=t.z/e),this}setAxisAngleFromRotationMatrix(t){let e,n,i,r,c=t.elements,l=c[0],h=c[4],f=c[8],u=c[1],d=c[5],g=c[9],v=c[2],m=c[6],p=c[10];if(Math.abs(h-u)<.01&&Math.abs(f-v)<.01&&Math.abs(g-m)<.01){if(Math.abs(h+u)<.1&&Math.abs(f+v)<.1&&Math.abs(g+m)<.1&&Math.abs(l+d+p-3)<.1)return this.set(1,0,0,0),this;e=Math.PI;let M=(l+1)/2,y=(d+1)/2,S=(p+1)/2,T=(h+u)/4,_=(f+v)/4,b=(g+m)/4;return M>y&&M>S?M<.01?(n=0,i=.707106781,r=.707106781):(n=Math.sqrt(M),i=T/n,r=_/n):y>S?y<.01?(n=.707106781,i=0,r=.707106781):(i=Math.sqrt(y),n=T/i,r=b/i):S<.01?(n=.707106781,i=.707106781,r=0):(r=Math.sqrt(S),n=_/r,i=b/r),this.set(n,i,r,e),this}let x=Math.sqrt((m-g)*(m-g)+(f-v)*(f-v)+(u-h)*(u-h));return Math.abs(x)<.001&&(x=1),this.x=(m-g)/x,this.y=(f-v)/x,this.z=(u-h)/x,this.w=Math.acos((l+d+p-1)/2),this}setFromMatrixPosition(t){let e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this.w=e[15],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this.w=Math.min(this.w,t.w),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this.w=Math.max(this.w,t.w),this}clamp(t,e){return this.x=kt(this.x,t.x,e.x),this.y=kt(this.y,t.y,e.y),this.z=kt(this.z,t.z,e.z),this.w=kt(this.w,t.w,e.w),this}clampScalar(t,e){return this.x=kt(this.x,t,e),this.y=kt(this.y,t,e),this.z=kt(this.z,t,e),this.w=kt(this.w,t,e),this}clampLength(t,e){let n=this.length();return this.divideScalar(n||1).multiplyScalar(kt(n,t,e))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z+this.w*t.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this.w+=(t.w-this.w)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this.w=t.w+(e.w-t.w)*n,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z&&t.w===this.w}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this.w=t[e+3],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t[e+3]=this.w,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this.w=t.getW(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}};$h.prototype.isVector4=!0;var Zt=$h,Va=class extends Qn{constructor(t=1,e=1,n={}){super(),n=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:we,depthBuffer:!0,stencilBuffer:!1,resolveColorBuffer:!0,resolveDepthBuffer:!0,resolveStencilBuffer:!0,storeMultisampledColorBuffer:!0,storeMultisampledDepthBuffer:!0,storeMultisampledStencilBuffer:!0,depthTexture:null,samples:0,count:1,depth:1,multiview:!1,useArrayDepthTexture:!1},n),this.isRenderTarget=!0,this.width=t,this.height=e,this.depth=n.depth,this.scissor=new Zt(0,0,t,e),this.scissorTest=!1,this.viewport=new Zt(0,0,t,e),this.textures=[];let i=n.count;for(let r=0;r<i;r++)this.textures[r]=new ke({width:t,height:e,depth:n.depth}),this.textures[r].isRenderTargetTexture=!0,this.textures[r].renderTarget=this;this._setTextureOptions(n),this.depthBuffer=n.depthBuffer,this.stencilBuffer=n.stencilBuffer,this.resolveColorBuffer=n.resolveColorBuffer,this.resolveDepthBuffer=n.resolveDepthBuffer,this.resolveStencilBuffer=n.resolveStencilBuffer,this.storeMultisampledColorBuffer=n.storeMultisampledColorBuffer,this.storeMultisampledDepthBuffer=n.storeMultisampledDepthBuffer,this.storeMultisampledStencilBuffer=n.storeMultisampledStencilBuffer,this._depthTexture=null,this.depthTexture=n.depthTexture,this.samples=n.samples,this.multiview=n.multiview,this.useArrayDepthTexture=n.useArrayDepthTexture}_setTextureOptions(t={}){let e={minFilter:we,generateMipmaps:!1,flipY:!1,internalFormat:null};t.mapping!==void 0&&(e.mapping=t.mapping),t.wrapS!==void 0&&(e.wrapS=t.wrapS),t.wrapT!==void 0&&(e.wrapT=t.wrapT),t.wrapR!==void 0&&(e.wrapR=t.wrapR),t.magFilter!==void 0&&(e.magFilter=t.magFilter),t.minFilter!==void 0&&(e.minFilter=t.minFilter),t.format!==void 0&&(e.format=t.format),t.type!==void 0&&(e.type=t.type),t.anisotropy!==void 0&&(e.anisotropy=t.anisotropy),t.colorSpace!==void 0&&(e.colorSpace=t.colorSpace),t.flipY!==void 0&&(e.flipY=t.flipY),t.generateMipmaps!==void 0&&(e.generateMipmaps=t.generateMipmaps),t.mipmapsAutoUpdate!==void 0&&(e.mipmapsAutoUpdate=t.mipmapsAutoUpdate),t.internalFormat!==void 0&&(e.internalFormat=t.internalFormat);for(let n=0;n<this.textures.length;n++)this.textures[n].setValues(e)}get texture(){return this.textures[0]}set texture(t){this.textures[0]=t}set depthTexture(t){this._depthTexture!==null&&this._depthTexture.renderTarget===this&&(this._depthTexture.renderTarget=null),t!==null&&t.renderTarget===null&&(t.renderTarget=this),this._depthTexture=t}get depthTexture(){return this._depthTexture}setSize(t,e,n=1){if(this.width!==t||this.height!==e||this.depth!==n){this.width=t,this.height=e,this.depth=n;for(let i=0,r=this.textures.length;i<r;i++)this.textures[i].image.width=t,this.textures[i].image.height=e,this.textures[i].image.depth=n,this.textures[i].isData3DTexture!==!0&&(this.textures[i].isArrayTexture=this.textures[i].image.depth>1);this.dispose()}this.viewport.set(0,0,t,e),this.scissor.set(0,0,t,e)}clone(){return new this.constructor().copy(this)}copy(t){this.width=t.width,this.height=t.height,this.depth=t.depth,this.scissor.copy(t.scissor),this.scissorTest=t.scissorTest,this.viewport.copy(t.viewport),this.textures.length=0;for(let e=0,n=t.textures.length;e<n;e++){this.textures[e]=t.textures[e].clone(),this.textures[e].isRenderTargetTexture=!0,this.textures[e].renderTarget=this;let i=Object.assign({},t.textures[e].image);this.textures[e].source=new rr(i)}if(this.depthBuffer=t.depthBuffer,this.stencilBuffer=t.stencilBuffer,this.resolveColorBuffer=t.resolveColorBuffer,this.resolveDepthBuffer=t.resolveDepthBuffer,this.resolveStencilBuffer=t.resolveStencilBuffer,this.storeMultisampledColorBuffer=t.storeMultisampledColorBuffer,this.storeMultisampledDepthBuffer=t.storeMultisampledDepthBuffer,this.storeMultisampledStencilBuffer=t.storeMultisampledStencilBuffer,t.depthTexture!==null)if(t.depthTexture.renderTarget===t){let e=t.depthTexture.clone();e.renderTarget=null,this.depthTexture=e}else this.depthTexture=t.depthTexture;else this.depthTexture=null;return this.samples=t.samples,this.multiview=t.multiview,this.useArrayDepthTexture=t.useArrayDepthTexture,this}dispose(){this.dispatchEvent({type:"dispose"})}},je=class extends Va{constructor(t=1,e=1,n={}){super(t,e,n),this.isWebGLRenderTarget=!0}},so=class extends ke{constructor(t=null,e=1,n=1,i=1){super(null),this.isDataArrayTexture=!0,this.image={data:t,width:e,height:n,depth:i},this.magFilter=xe,this.minFilter=xe,this.wrapR=xn,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1,this.layerUpdates=new Set}copy(t){return super.copy(t),this.wrapR=t.wrapR,this}addLayerUpdate(t){this.layerUpdates.add(t)}clearLayerUpdates(){this.layerUpdates.clear()}};var Ga=class extends ke{constructor(t=null,e=1,n=1,i=1){super(null),this.isData3DTexture=!0,this.image={data:t,width:e,height:n,depth:i},this.magFilter=xe,this.minFilter=xe,this.wrapR=xn,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}copy(t){return super.copy(t),this.wrapR=t.wrapR,this}};var nc=class nc{constructor(t,e,n,i,r,o,a,c,l,h,f,u,d,g,v,m){this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],t!==void 0&&this.set(t,e,n,i,r,o,a,c,l,h,f,u,d,g,v,m)}set(t,e,n,i,r,o,a,c,l,h,f,u,d,g,v,m){let p=this.elements;return p[0]=t,p[4]=e,p[8]=n,p[12]=i,p[1]=r,p[5]=o,p[9]=a,p[13]=c,p[2]=l,p[6]=h,p[10]=f,p[14]=u,p[3]=d,p[7]=g,p[11]=v,p[15]=m,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new nc().fromArray(this.elements)}copy(t){let e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],e[9]=n[9],e[10]=n[10],e[11]=n[11],e[12]=n[12],e[13]=n[13],e[14]=n[14],e[15]=n[15],this}copyPosition(t){let e=this.elements,n=t.elements;return e[12]=n[12],e[13]=n[13],e[14]=n[14],this}setFromMatrix3(t){let e=t.elements;return this.set(e[0],e[3],e[6],0,e[1],e[4],e[7],0,e[2],e[5],e[8],0,0,0,0,1),this}extractBasis(t,e,n){return this.determinantAffine()===0?(t.set(1,0,0),e.set(0,1,0),n.set(0,0,1),this):(t.setFromMatrixColumn(this,0),e.setFromMatrixColumn(this,1),n.setFromMatrixColumn(this,2),this)}makeBasis(t,e,n){return this.set(t.x,e.x,n.x,0,t.y,e.y,n.y,0,t.z,e.z,n.z,0,0,0,0,1),this}extractRotation(t){if(t.determinantAffine()===0)return this.identity();let e=this.elements,n=t.elements,i=1/Bs.setFromMatrixColumn(t,0).length(),r=1/Bs.setFromMatrixColumn(t,1).length(),o=1/Bs.setFromMatrixColumn(t,2).length();return e[0]=n[0]*i,e[1]=n[1]*i,e[2]=n[2]*i,e[3]=0,e[4]=n[4]*r,e[5]=n[5]*r,e[6]=n[6]*r,e[7]=0,e[8]=n[8]*o,e[9]=n[9]*o,e[10]=n[10]*o,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromEuler(t){let e=this.elements,n=t.x,i=t.y,r=t.z,o=Math.cos(n),a=Math.sin(n),c=Math.cos(i),l=Math.sin(i),h=Math.cos(r),f=Math.sin(r);if(t.order==="XYZ"){let u=o*h,d=o*f,g=a*h,v=a*f;e[0]=c*h,e[4]=-c*f,e[8]=l,e[1]=d+g*l,e[5]=u-v*l,e[9]=-a*c,e[2]=v-u*l,e[6]=g+d*l,e[10]=o*c}else if(t.order==="YXZ"){let u=c*h,d=c*f,g=l*h,v=l*f;e[0]=u+v*a,e[4]=g*a-d,e[8]=o*l,e[1]=o*f,e[5]=o*h,e[9]=-a,e[2]=d*a-g,e[6]=v+u*a,e[10]=o*c}else if(t.order==="ZXY"){let u=c*h,d=c*f,g=l*h,v=l*f;e[0]=u-v*a,e[4]=-o*f,e[8]=g+d*a,e[1]=d+g*a,e[5]=o*h,e[9]=v-u*a,e[2]=-o*l,e[6]=a,e[10]=o*c}else if(t.order==="ZYX"){let u=o*h,d=o*f,g=a*h,v=a*f;e[0]=c*h,e[4]=g*l-d,e[8]=u*l+v,e[1]=c*f,e[5]=v*l+u,e[9]=d*l-g,e[2]=-l,e[6]=a*c,e[10]=o*c}else if(t.order==="YZX"){let u=o*c,d=o*l,g=a*c,v=a*l;e[0]=c*h,e[4]=v-u*f,e[8]=g*f+d,e[1]=f,e[5]=o*h,e[9]=-a*h,e[2]=-l*h,e[6]=d*f+g,e[10]=u-v*f}else if(t.order==="XZY"){let u=o*c,d=o*l,g=a*c,v=a*l;e[0]=c*h,e[4]=-f,e[8]=l*h,e[1]=u*f+v,e[5]=o*h,e[9]=d*f-g,e[2]=g*f-d,e[6]=a*h,e[10]=v*f+u}return e[3]=0,e[7]=0,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromQuaternion(t){return this.compose(ig,t,sg)}lookAt(t,e,n){let i=this.elements;return bn.subVectors(t,e),bn.lengthSq()===0&&(bn.z=1),bn.normalize(),Gi.crossVectors(n,bn),Gi.lengthSq()===0&&(Math.abs(n.z)===1?bn.x+=1e-4:bn.z+=1e-4,bn.normalize(),Gi.crossVectors(n,bn)),Gi.normalize(),ra.crossVectors(bn,Gi),i[0]=Gi.x,i[4]=ra.x,i[8]=bn.x,i[1]=Gi.y,i[5]=ra.y,i[9]=bn.y,i[2]=Gi.z,i[6]=ra.z,i[10]=bn.z,this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){let n=t.elements,i=e.elements,r=this.elements,o=n[0],a=n[4],c=n[8],l=n[12],h=n[1],f=n[5],u=n[9],d=n[13],g=n[2],v=n[6],m=n[10],p=n[14],x=n[3],M=n[7],y=n[11],S=n[15],T=i[0],_=i[4],b=i[8],I=i[12],E=i[1],L=i[5],C=i[9],U=i[13],N=i[2],B=i[6],G=i[10],H=i[14],tt=i[3],X=i[7],j=i[11],Q=i[15];return r[0]=o*T+a*E+c*N+l*tt,r[4]=o*_+a*L+c*B+l*X,r[8]=o*b+a*C+c*G+l*j,r[12]=o*I+a*U+c*H+l*Q,r[1]=h*T+f*E+u*N+d*tt,r[5]=h*_+f*L+u*B+d*X,r[9]=h*b+f*C+u*G+d*j,r[13]=h*I+f*U+u*H+d*Q,r[2]=g*T+v*E+m*N+p*tt,r[6]=g*_+v*L+m*B+p*X,r[10]=g*b+v*C+m*G+p*j,r[14]=g*I+v*U+m*H+p*Q,r[3]=x*T+M*E+y*N+S*tt,r[7]=x*_+M*L+y*B+S*X,r[11]=x*b+M*C+y*G+S*j,r[15]=x*I+M*U+y*H+S*Q,this}multiplyScalar(t){let e=this.elements;return e[0]*=t,e[4]*=t,e[8]*=t,e[12]*=t,e[1]*=t,e[5]*=t,e[9]*=t,e[13]*=t,e[2]*=t,e[6]*=t,e[10]*=t,e[14]*=t,e[3]*=t,e[7]*=t,e[11]*=t,e[15]*=t,this}determinant(){let t=this.elements,e=t[0],n=t[4],i=t[8],r=t[12],o=t[1],a=t[5],c=t[9],l=t[13],h=t[2],f=t[6],u=t[10],d=t[14],g=t[3],v=t[7],m=t[11],p=t[15],x=c*d-l*u,M=a*d-l*f,y=a*u-c*f,S=o*d-l*h,T=o*u-c*h,_=o*f-a*h;return e*(v*x-m*M+p*y)-n*(g*x-m*S+p*T)+i*(g*M-v*S+p*_)-r*(g*y-v*T+m*_)}determinantAffine(){let t=this.elements,e=t[0],n=t[4],i=t[8],r=t[1],o=t[5],a=t[9],c=t[2],l=t[6],h=t[10];return e*(o*h-a*l)-n*(r*h-a*c)+i*(r*l-o*c)}transpose(){let t=this.elements,e;return e=t[1],t[1]=t[4],t[4]=e,e=t[2],t[2]=t[8],t[8]=e,e=t[6],t[6]=t[9],t[9]=e,e=t[3],t[3]=t[12],t[12]=e,e=t[7],t[7]=t[13],t[13]=e,e=t[11],t[11]=t[14],t[14]=e,this}setPosition(t,e,n){let i=this.elements;return t.isVector3?(i[12]=t.x,i[13]=t.y,i[14]=t.z):(i[12]=t,i[13]=e,i[14]=n),this}invert(){let t=this.elements,e=t[0],n=t[1],i=t[2],r=t[3],o=t[4],a=t[5],c=t[6],l=t[7],h=t[8],f=t[9],u=t[10],d=t[11],g=t[12],v=t[13],m=t[14],p=t[15],x=e*a-n*o,M=e*c-i*o,y=e*l-r*o,S=n*c-i*a,T=n*l-r*a,_=i*l-r*c,b=h*v-f*g,I=h*m-u*g,E=h*p-d*g,L=f*m-u*v,C=f*p-d*v,U=u*p-d*m,N=x*U-M*C+y*L+S*E-T*I+_*b;if(N===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);let B=1/N;return t[0]=(a*U-c*C+l*L)*B,t[1]=(i*C-n*U-r*L)*B,t[2]=(v*_-m*T+p*S)*B,t[3]=(u*T-f*_-d*S)*B,t[4]=(c*E-o*U-l*I)*B,t[5]=(e*U-i*E+r*I)*B,t[6]=(m*y-g*_-p*M)*B,t[7]=(h*_-u*y+d*M)*B,t[8]=(o*C-a*E+l*b)*B,t[9]=(n*E-e*C-r*b)*B,t[10]=(g*T-v*y+p*x)*B,t[11]=(f*y-h*T-d*x)*B,t[12]=(a*I-o*L-c*b)*B,t[13]=(e*L-n*I+i*b)*B,t[14]=(v*M-g*S-m*x)*B,t[15]=(h*S-f*M+u*x)*B,this}scale(t){let e=this.elements,n=t.x,i=t.y,r=t.z;return e[0]*=n,e[4]*=i,e[8]*=r,e[1]*=n,e[5]*=i,e[9]*=r,e[2]*=n,e[6]*=i,e[10]*=r,e[3]*=n,e[7]*=i,e[11]*=r,this}getMaxScaleOnAxis(){let t=this.elements,e=t[0]*t[0]+t[1]*t[1]+t[2]*t[2],n=t[4]*t[4]+t[5]*t[5]+t[6]*t[6],i=t[8]*t[8]+t[9]*t[9]+t[10]*t[10];return Math.sqrt(Math.max(e,n,i))}makeTranslation(t,e,n){return t.isVector3?this.set(1,0,0,t.x,0,1,0,t.y,0,0,1,t.z,0,0,0,1):this.set(1,0,0,t,0,1,0,e,0,0,1,n,0,0,0,1),this}makeRotationX(t){let e=Math.cos(t),n=Math.sin(t);return this.set(1,0,0,0,0,e,-n,0,0,n,e,0,0,0,0,1),this}makeRotationY(t){let e=Math.cos(t),n=Math.sin(t);return this.set(e,0,n,0,0,1,0,0,-n,0,e,0,0,0,0,1),this}makeRotationZ(t){let e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,0,n,e,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(t,e){let n=Math.cos(e),i=Math.sin(e),r=1-n,o=t.x,a=t.y,c=t.z,l=r*o,h=r*a;return this.set(l*o+n,l*a-i*c,l*c+i*a,0,l*a+i*c,h*a+n,h*c-i*o,0,l*c-i*a,h*c+i*o,r*c*c+n,0,0,0,0,1),this}makeScale(t,e,n){return this.set(t,0,0,0,0,e,0,0,0,0,n,0,0,0,0,1),this}makeShear(t,e,n,i,r,o){return this.set(1,n,r,0,t,1,o,0,e,i,1,0,0,0,0,1),this}compose(t,e,n){let i=this.elements,r=e._x,o=e._y,a=e._z,c=e._w,l=r+r,h=o+o,f=a+a,u=r*l,d=r*h,g=r*f,v=o*h,m=o*f,p=a*f,x=c*l,M=c*h,y=c*f,S=n.x,T=n.y,_=n.z;return i[0]=(1-(v+p))*S,i[1]=(d+y)*S,i[2]=(g-M)*S,i[3]=0,i[4]=(d-y)*T,i[5]=(1-(u+p))*T,i[6]=(m+x)*T,i[7]=0,i[8]=(g+M)*_,i[9]=(m-x)*_,i[10]=(1-(u+v))*_,i[11]=0,i[12]=t.x,i[13]=t.y,i[14]=t.z,i[15]=1,this}decompose(t,e,n){let i=this.elements;t.x=i[12],t.y=i[13],t.z=i[14];let r=this.determinantAffine();if(r===0)return n.set(1,1,1),e.identity(),this;let o=Bs.set(i[0],i[1],i[2]).length(),a=Bs.set(i[4],i[5],i[6]).length(),c=Bs.set(i[8],i[9],i[10]).length();r<0&&(o=-o),kn.copy(this);let l=1/o,h=1/a,f=1/c;return kn.elements[0]*=l,kn.elements[1]*=l,kn.elements[2]*=l,kn.elements[4]*=h,kn.elements[5]*=h,kn.elements[6]*=h,kn.elements[8]*=f,kn.elements[9]*=f,kn.elements[10]*=f,e.setFromRotationMatrix(kn),n.x=o,n.y=a,n.z=c,this}makePerspective(t,e,n,i,r,o,a=Dn,c=!1){let l=this.elements,h=2*r/(e-t),f=2*r/(n-i),u=(e+t)/(e-t),d=(n+i)/(n-i),g,v;if(c)g=r/(o-r),v=o*r/(o-r);else if(a===Dn)g=-(o+r)/(o-r),v=-2*o*r/(o-r);else if(a===nr)g=-o/(o-r),v=-o*r/(o-r);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+a);return l[0]=h,l[4]=0,l[8]=u,l[12]=0,l[1]=0,l[5]=f,l[9]=d,l[13]=0,l[2]=0,l[6]=0,l[10]=g,l[14]=v,l[3]=0,l[7]=0,l[11]=-1,l[15]=0,this}makeOrthographic(t,e,n,i,r,o,a=Dn,c=!1){let l=this.elements,h=2/(e-t),f=2/(n-i),u=-(e+t)/(e-t),d=-(n+i)/(n-i),g,v;if(c)g=1/(o-r),v=o/(o-r);else if(a===Dn)g=-2/(o-r),v=-(o+r)/(o-r);else if(a===nr)g=-1/(o-r),v=-r/(o-r);else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+a);return l[0]=h,l[4]=0,l[8]=0,l[12]=u,l[1]=0,l[5]=f,l[9]=0,l[13]=d,l[2]=0,l[6]=0,l[10]=g,l[14]=v,l[3]=0,l[7]=0,l[11]=0,l[15]=1,this}equals(t){let e=this.elements,n=t.elements;for(let i=0;i<16;i++)if(e[i]!==n[i])return!1;return!0}fromArray(t,e=0){for(let n=0;n<16;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){let n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t[e+9]=n[9],t[e+10]=n[10],t[e+11]=n[11],t[e+12]=n[12],t[e+13]=n[13],t[e+14]=n[14],t[e+15]=n[15],t}};nc.prototype.isMatrix4=!0;var _t=nc,Bs=new R,kn=new _t,ig=new R(0,0,0),sg=new R(1,1,1),Gi=new R,ra=new R,bn=new R,Pf=new _t,If=new wn,Ti=class s{constructor(t=0,e=0,n=0,i=s.DEFAULT_ORDER){this.isEuler=!0,this._x=t,this._y=e,this._z=n,this._order=i}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get order(){return this._order}set order(t){this._order=t,this._onChangeCallback()}set(t,e,n,i=this._order){return this._x=t,this._y=e,this._z=n,this._order=i,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(t){return this._x=t._x,this._y=t._y,this._z=t._z,this._order=t._order,this._onChangeCallback(),this}setFromRotationMatrix(t,e=this._order,n=!0){let i=t.elements,r=i[0],o=i[4],a=i[8],c=i[1],l=i[5],h=i[9],f=i[2],u=i[6],d=i[10];switch(e){case"XYZ":this._y=Math.asin(kt(a,-1,1)),Math.abs(a)<.9999999?(this._x=Math.atan2(-h,d),this._z=Math.atan2(-o,r)):(this._x=Math.atan2(u,l),this._z=0);break;case"YXZ":this._x=Math.asin(-kt(h,-1,1)),Math.abs(h)<.9999999?(this._y=Math.atan2(a,d),this._z=Math.atan2(c,l)):(this._y=Math.atan2(-f,r),this._z=0);break;case"ZXY":this._x=Math.asin(kt(u,-1,1)),Math.abs(u)<.9999999?(this._y=Math.atan2(-f,d),this._z=Math.atan2(-o,l)):(this._y=0,this._z=Math.atan2(c,r));break;case"ZYX":this._y=Math.asin(-kt(f,-1,1)),Math.abs(f)<.9999999?(this._x=Math.atan2(u,d),this._z=Math.atan2(c,r)):(this._x=0,this._z=Math.atan2(-o,l));break;case"YZX":this._z=Math.asin(kt(c,-1,1)),Math.abs(c)<.9999999?(this._x=Math.atan2(-h,l),this._y=Math.atan2(-f,r)):(this._x=0,this._y=Math.atan2(a,d));break;case"XZY":this._z=Math.asin(-kt(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(u,l),this._y=Math.atan2(a,r)):(this._x=Math.atan2(-h,d),this._y=0);break;default:Tt("Euler: .setFromRotationMatrix() encountered an unknown order: "+e)}return this._order=e,n===!0&&this._onChangeCallback(),this}setFromQuaternion(t,e,n){return Pf.makeRotationFromQuaternion(t),this.setFromRotationMatrix(Pf,e,n)}setFromVector3(t,e=this._order){return this.set(t.x,t.y,t.z,e)}reorder(t){return If.setFromEuler(this),this.setFromQuaternion(If,t)}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._order===this._order}fromArray(t){return this._x=t[0],this._y=t[1],this._z=t[2],t[3]!==void 0&&(this._order=t[3]),this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._order,t}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}};Ti.DEFAULT_ORDER="XYZ";var or=class{constructor(){this.mask=1}set(t){this.mask=(1<<t|0)>>>0}enable(t){this.mask|=1<<t|0}enableAll(){this.mask=-1}toggle(t){this.mask^=1<<t|0}disable(t){this.mask&=~(1<<t|0)}disableAll(){this.mask=0}test(t){return(this.mask&t.mask)!==0}isEnabled(t){return(this.mask&(1<<t|0))!==0}},rg=0,Lf=new R,zs=new wn,mi=new _t,oa=new R,Xr=new R,og=new R,ag=new wn,Nf=new R(1,0,0),Df=new R(0,1,0),Uf=new R(0,0,1),Ff={type:"added"},cg={type:"removed"},ks={type:"childadded",child:null},zl={type:"childremoved",child:null},Ae=class s extends Qn{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:rg++}),this.uuid=oi(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=s.DEFAULT_UP.clone();let t=new R,e=new Ti,n=new wn,i=new R(1,1,1);function r(){n.setFromEuler(e,!1)}function o(){e.setFromQuaternion(n,void 0,!1)}e._onChange(r),n._onChange(o),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:t},rotation:{configurable:!0,enumerable:!0,value:e},quaternion:{configurable:!0,enumerable:!0,value:n},scale:{configurable:!0,enumerable:!0,value:i},modelViewMatrix:{value:new _t},normalMatrix:{value:new Ft}}),this.matrix=new _t,this.matrixWorld=new _t,this.matrixAutoUpdate=s.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=s.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new or,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.customDepthMaterial=void 0,this.customDistanceMaterial=void 0,this.static=!1,this.userData={},this.pivot=null}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(t){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(t),this.matrix.decompose(this.position,this.quaternion,this.scale),this.pivot!==null&&this.position.copy(this.pivot).applyMatrix4(this.matrix).sub(this.pivot)}applyQuaternion(t){return this.quaternion.premultiply(t),this}setRotationFromAxisAngle(t,e){this.quaternion.setFromAxisAngle(t,e)}setRotationFromEuler(t){this.quaternion.setFromEuler(t,!0)}setRotationFromMatrix(t){this.quaternion.setFromRotationMatrix(t)}setRotationFromQuaternion(t){this.quaternion.copy(t)}rotateOnAxis(t,e){return zs.setFromAxisAngle(t,e),this.quaternion.multiply(zs),this}rotateOnWorldAxis(t,e){return zs.setFromAxisAngle(t,e),this.quaternion.premultiply(zs),this}rotateX(t){return this.rotateOnAxis(Nf,t)}rotateY(t){return this.rotateOnAxis(Df,t)}rotateZ(t){return this.rotateOnAxis(Uf,t)}translateOnAxis(t,e){return Lf.copy(t).applyQuaternion(this.quaternion),this.position.add(Lf.multiplyScalar(e)),this}translateX(t){return this.translateOnAxis(Nf,t)}translateY(t){return this.translateOnAxis(Df,t)}translateZ(t){return this.translateOnAxis(Uf,t)}localToWorld(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(this.matrixWorld)}worldToLocal(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(mi.copy(this.matrixWorld).invert())}lookAt(t,e,n){t.isVector3?oa.copy(t):oa.set(t,e,n);let i=this.parent;this.updateWorldMatrix(!0,!1),Xr.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?mi.lookAt(Xr,oa,this.up):mi.lookAt(oa,Xr,this.up),this.quaternion.setFromRotationMatrix(mi),i&&(mi.extractRotation(i.matrixWorld),zs.setFromRotationMatrix(mi),this.quaternion.premultiply(zs.invert()))}add(t){if(arguments.length>1){for(let e=0;e<arguments.length;e++)this.add(arguments[e]);return this}return t===this?(Dt("Object3D.add: object can't be added as a child of itself.",t),this):(t&&t.isObject3D?(t.removeFromParent(),t.parent=this,this.children.push(t),t.dispatchEvent(Ff),ks.child=t,this.dispatchEvent(ks),ks.child=null):Dt("Object3D.add: object not an instance of THREE.Object3D.",t),this)}remove(t){if(arguments.length>1){for(let n=0;n<arguments.length;n++)this.remove(arguments[n]);return this}let e=this.children.indexOf(t);return e!==-1&&(t.parent=null,this.children.splice(e,1),t.dispatchEvent(cg),zl.child=t,this.dispatchEvent(zl),zl.child=null),this}removeFromParent(){let t=this.parent;return t!==null&&t.remove(this),this}clear(){return this.remove(...this.children)}attach(t){return this.updateWorldMatrix(!0,!1),mi.copy(this.matrixWorld).invert(),t.parent!==null&&(t.parent.updateWorldMatrix(!0,!1),mi.multiply(t.parent.matrixWorld)),t.applyMatrix4(mi),t.removeFromParent(),t.parent=this,this.children.push(t),t.updateWorldMatrix(!1,!0),t.dispatchEvent(Ff),ks.child=t,this.dispatchEvent(ks),ks.child=null,this}getObjectById(t){return this.getObjectByProperty("id",t)}getObjectByName(t){return this.getObjectByProperty("name",t)}getObjectByProperty(t,e){if(this[t]===e)return this;for(let n=0,i=this.children.length;n<i;n++){let o=this.children[n].getObjectByProperty(t,e);if(o!==void 0)return o}}getObjectsByProperty(t,e,n=[]){this[t]===e&&n.push(this);let i=this.children;for(let r=0,o=i.length;r<o;r++)i[r].getObjectsByProperty(t,e,n);return n}getWorldPosition(t){return this.updateWorldMatrix(!0,!1),t.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Xr,t,og),t}getWorldScale(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(Xr,ag,t),t}getWorldDirection(t){this.updateWorldMatrix(!0,!1);let e=this.matrixWorld.elements;return t.set(e[8],e[9],e[10]).normalize()}raycast(){}intersectsFrustum(){return!0}traverse(t){t(this);let e=this.children;for(let n=0,i=e.length;n<i;n++)e[n].traverse(t)}traverseVisible(t){if(this.visible===!1)return;t(this);let e=this.children;for(let n=0,i=e.length;n<i;n++)e[n].traverseVisible(t)}traverseAncestors(t){let e=this.parent;e!==null&&(t(e),e.traverseAncestors(t))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale);let t=this.pivot;if(t!==null){let e=t.x,n=t.y,i=t.z,r=this.matrix.elements;r[12]+=e-r[0]*e-r[4]*n-r[8]*i,r[13]+=n-r[1]*e-r[5]*n-r[9]*i,r[14]+=i-r[2]*e-r[6]*n-r[10]*i}this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(t){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||t)&&(this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),this.matrixWorldNeedsUpdate=!1,t=!0);let e=this.children;for(let n=0,i=e.length;n<i;n++)e[n].updateMatrixWorld(t)}updateWorldMatrix(t,e,n=!1){let i=this.parent;if(t===!0&&i!==null&&i.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||n)&&(this.matrixWorldAutoUpdate===!0&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix)),this.matrixWorldNeedsUpdate=!1,n=!0),e===!0){let r=this.children;for(let o=0,a=r.length;o<a;o++)r[o].updateWorldMatrix(!1,!0,n)}}toJSON(t){let e=t===void 0||typeof t=="string",n={};e&&(t={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},n.metadata={version:4.7,type:"Object",generator:"Object3D.toJSON"});let i={};i.uuid=this.uuid,i.type=this.type,i.name=this.name,i.castShadow=this.castShadow,i.receiveShadow=this.receiveShadow,i.visible=this.visible,i.frustumCulled=this.frustumCulled,i.renderOrder=this.renderOrder,i.static=this.static,i.matrixAutoUpdate=this.matrixAutoUpdate,Object.keys(this.userData).length>0&&(i.userData=this.userData),i.layers=this.layers.mask,i.matrix=this.matrix.toArray(),i.up=this.up.toArray(),this.pivot!==null&&(i.pivot=this.pivot.toArray()),this.morphTargetDictionary!==void 0&&(i.morphTargetDictionary=Object.assign({},this.morphTargetDictionary)),this.morphTargetInfluences!==void 0&&(i.morphTargetInfluences=this.morphTargetInfluences.slice()),this.isInstancedMesh&&(i.type="InstancedMesh",i.count=this.count,i.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(i.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(i.type="BatchedMesh",i.perObjectFrustumCulled=this.perObjectFrustumCulled,i.sortObjects=this.sortObjects,i.drawRanges=this._drawRanges,i.reservedRanges=this._reservedRanges,i.geometryInfo=this._geometryInfo.map(a=>({...a,boundingBox:a.boundingBox?a.boundingBox.toJSON():void 0,boundingSphere:a.boundingSphere?a.boundingSphere.toJSON():void 0})),i.instanceInfo=this._instanceInfo.map(a=>({...a})),i.availableInstanceIds=this._availableInstanceIds.slice(),i.availableGeometryIds=this._availableGeometryIds.slice(),i.nextIndexStart=this._nextIndexStart,i.nextVertexStart=this._nextVertexStart,i.geometryCount=this._geometryCount,i.maxInstanceCount=this._maxInstanceCount,i.maxVertexCount=this._maxVertexCount,i.maxIndexCount=this._maxIndexCount,i.geometryInitialized=this._geometryInitialized,i.matricesTexture=this._matricesTexture.toJSON(t),i.indirectTexture=this._indirectTexture.toJSON(t),this._colorsTexture!==null&&(i.colorsTexture=this._colorsTexture.toJSON(t)),this.boundingSphere!==null&&(i.boundingSphere=this.boundingSphere.toJSON()),this.boundingBox!==null&&(i.boundingBox=this.boundingBox.toJSON()));function r(a,c){return a[c.uuid]===void 0&&(a[c.uuid]=c.toJSON(t)),c.uuid}if(this.isScene)this.background&&(this.background.isColor?i.background=this.background.toJSON():this.background.isTexture&&(i.background=this.background.toJSON(t).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(i.environment=this.environment.toJSON(t).uuid);else if(this.isMesh||this.isLine||this.isPoints){i.geometry=r(t.geometries,this.geometry);let a=this.geometry.parameters;if(a!==void 0&&a.shapes!==void 0){let c=a.shapes;if(Array.isArray(c))for(let l=0,h=c.length;l<h;l++){let f=c[l];r(t.shapes,f)}else r(t.shapes,c)}}if(this.isSkinnedMesh&&(i.bindMode=this.bindMode,i.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(r(t.skeletons,this.skeleton),i.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){let a=[];for(let c=0,l=this.material.length;c<l;c++)a.push(r(t.materials,this.material[c]));i.material=a}else i.material=r(t.materials,this.material);if(this.children.length>0){i.children=[];for(let a=0;a<this.children.length;a++)i.children.push(this.children[a].toJSON(t).object)}if(this.animations.length>0){i.animations=[];for(let a=0;a<this.animations.length;a++){let c=this.animations[a];i.animations.push(r(t.animations,c))}}if(e){let a=o(t.geometries),c=o(t.materials),l=o(t.textures),h=o(t.images),f=o(t.shapes),u=o(t.skeletons),d=o(t.animations),g=o(t.nodes);a.length>0&&(n.geometries=a),c.length>0&&(n.materials=c),l.length>0&&(n.textures=l),h.length>0&&(n.images=h),f.length>0&&(n.shapes=f),u.length>0&&(n.skeletons=u),d.length>0&&(n.animations=d),g.length>0&&(n.nodes=g)}return n.object=i,n;function o(a){let c=[];for(let l in a){let h=a[l];delete h.metadata,c.push(h)}return c}}clone(t){return new this.constructor().copy(this,t)}copy(t,e=!0){if(this.name=t.name,this.up.copy(t.up),this.position.copy(t.position),this.rotation.order=t.rotation.order,this.quaternion.copy(t.quaternion),this.scale.copy(t.scale),this.pivot=t.pivot!==null?t.pivot.clone():null,this.matrix.copy(t.matrix),this.matrixWorld.copy(t.matrixWorld),this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrixWorldAutoUpdate=t.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=t.matrixWorldNeedsUpdate,this.layers.mask=t.layers.mask,this.visible=t.visible,this.castShadow=t.castShadow,this.receiveShadow=t.receiveShadow,this.frustumCulled=t.frustumCulled,this.renderOrder=t.renderOrder,this.static=t.static,this.animations=t.animations.slice(),this.userData=JSON.parse(JSON.stringify(t.userData)),e===!0)for(let n=0;n<t.children.length;n++){let i=t.children[n];this.add(i.clone())}return this}dispose(){this.dispatchEvent({type:"dispose"})}};Ae.DEFAULT_UP=new R(0,1,0);Ae.DEFAULT_MATRIX_AUTO_UPDATE=!0;Ae.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;var Ye=class extends Ae{constructor(){super(),this.isGroup=!0,this.type="Group"}},lg={type:"move"},ar=class{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new Ye,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new Ye,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new R,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new R),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new Ye,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new R,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new R,this._grip.eventsEnabled=!1),this._grip}dispatchEvent(t){return this._targetRay!==null&&this._targetRay.dispatchEvent(t),this._grip!==null&&this._grip.dispatchEvent(t),this._hand!==null&&this._hand.dispatchEvent(t),this}connect(t){if(t&&t.hand){let e=this._hand;if(e)for(let n of t.hand.values())this._getHandJoint(e,n)}return this.dispatchEvent({type:"connected",data:t}),this}disconnect(t){return this.dispatchEvent({type:"disconnected",data:t}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(t,e,n){let i=null,r=null,o=null,a=this._targetRay,c=this._grip,l=this._hand;if(t&&e.session.visibilityState!=="visible-blurred"){if(l&&t.hand){o=!0;for(let v of t.hand.values()){let m=e.getJointPose(v,n),p=this._getHandJoint(l,v);m!==null&&(p.matrix.fromArray(m.transform.matrix),p.matrix.decompose(p.position,p.quaternion,p.scale),p.matrixWorldNeedsUpdate=!0,p.jointRadius=m.radius),p.visible=m!==null}let h=l.joints["index-finger-tip"],f=l.joints["thumb-tip"],u=h.position.distanceTo(f.position),d=.02,g=.005;l.inputState.pinching&&u>d+g?(l.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:t.handedness,target:this})):!l.inputState.pinching&&u<=d-g&&(l.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:t.handedness,target:this}))}else c!==null&&t.gripSpace&&(r=e.getPose(t.gripSpace,n),r!==null&&(c.matrix.fromArray(r.transform.matrix),c.matrix.decompose(c.position,c.quaternion,c.scale),c.matrixWorldNeedsUpdate=!0,r.linearVelocity?(c.hasLinearVelocity=!0,c.linearVelocity.copy(r.linearVelocity)):c.hasLinearVelocity=!1,r.angularVelocity?(c.hasAngularVelocity=!0,c.angularVelocity.copy(r.angularVelocity)):c.hasAngularVelocity=!1,c.eventsEnabled&&c.dispatchEvent({type:"gripUpdated",data:t,target:this})));a!==null&&(i=e.getPose(t.targetRaySpace,n),i===null&&r!==null&&(i=r),i!==null&&(a.matrix.fromArray(i.transform.matrix),a.matrix.decompose(a.position,a.quaternion,a.scale),a.matrixWorldNeedsUpdate=!0,i.linearVelocity?(a.hasLinearVelocity=!0,a.linearVelocity.copy(i.linearVelocity)):a.hasLinearVelocity=!1,i.angularVelocity?(a.hasAngularVelocity=!0,a.angularVelocity.copy(i.angularVelocity)):a.hasAngularVelocity=!1,this.dispatchEvent(lg)))}return a!==null&&(a.visible=i!==null),c!==null&&(c.visible=r!==null),l!==null&&(l.visible=o!==null),this}_getHandJoint(t,e){if(t.joints[e.jointName]===void 0){let n=new Ye;n.matrixAutoUpdate=!1,n.visible=!1,t.joints[e.jointName]=n,t.add(n)}return t.joints[e.jointName]}},$d={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},Hi={h:0,s:0,l:0},aa={h:0,s:0,l:0};function kl(s,t,e){return e<0&&(e+=1),e>1&&(e-=1),e<1/6?s+(t-s)*6*e:e<1/2?t:e<2/3?s+(t-s)*6*(2/3-e):s}var Pt=class{constructor(t,e,n){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(t,e,n)}set(t,e,n){if(e===void 0&&n===void 0){let i=t;i&&i.isColor?this.copy(i):typeof i=="number"?this.setHex(i):typeof i=="string"&&this.setStyle(i)}else this.setRGB(t,e,n);return this}setScalar(t){return this.r=t,this.g=t,this.b=t,this}setHex(t,e=ee){return t=Math.floor(t),this.r=(t>>16&255)/255,this.g=(t>>8&255)/255,this.b=(t&255)/255,Ht.colorSpaceToWorking(this,e),this}setRGB(t,e,n,i=Ht.workingColorSpace){return this.r=t,this.g=e,this.b=n,Ht.colorSpaceToWorking(this,i),this}setHSL(t,e,n,i=Ht.workingColorSpace){if(t=kh(t,1),e=kt(e,0,1),n=kt(n,0,1),e===0)this.r=this.g=this.b=n;else{let r=n<=.5?n*(1+e):n+e-n*e,o=2*n-r;this.r=kl(o,r,t+1/3),this.g=kl(o,r,t),this.b=kl(o,r,t-1/3)}return Ht.colorSpaceToWorking(this,i),this}setStyle(t,e=ee){function n(r){r!==void 0&&parseFloat(r)<1&&Tt("Color: Alpha component of "+t+" will be ignored.")}let i;if(i=/^(\w+)\(([^\)]*)\)/.exec(t)){let r,o=i[1],a=i[2];switch(o){case"rgb":case"rgba":if(r=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d+(?:\.\d+)?|\.\d+)\s*)?$/.exec(a))return n(r[4]),this.setRGB(Math.min(255,parseInt(r[1],10))/255,Math.min(255,parseInt(r[2],10))/255,Math.min(255,parseInt(r[3],10))/255,e);if(r=/^\s*(\d+(?:\.\d+)?|\.\d+)\%\s*,\s*(\d+(?:\.\d+)?|\.\d+)\%\s*,\s*(\d+(?:\.\d+)?|\.\d+)\%\s*(?:,\s*(\d+(?:\.\d+)?|\.\d+)\s*)?$/.exec(a))return n(r[4]),this.setRGB(Math.min(100,parseFloat(r[1]))/100,Math.min(100,parseFloat(r[2]))/100,Math.min(100,parseFloat(r[3]))/100,e);break;case"hsl":case"hsla":if(r=/^\s*([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s*,\s*(\d+(?:\.\d+)?|\.\d+)\%\s*,\s*(\d+(?:\.\d+)?|\.\d+)\%\s*(?:,\s*(\d+(?:\.\d+)?|\.\d+)\s*)?$/.exec(a))return n(r[4]),this.setHSL(parseFloat(r[1])/360,parseFloat(r[2])/100,parseFloat(r[3])/100,e);break;default:Tt("Color: Unknown color model "+t)}}else if(i=/^\#([A-Fa-f\d]+)$/.exec(t)){let r=i[1],o=r.length;if(o===3)return this.setRGB(parseInt(r.charAt(0),16)/15,parseInt(r.charAt(1),16)/15,parseInt(r.charAt(2),16)/15,e);if(o===6)return this.setHex(parseInt(r,16),e);Tt("Color: Invalid hex color "+t)}else if(t&&t.length>0)return this.setColorName(t,e);return this}setColorName(t,e=ee){let n=$d[t.toLowerCase()];return n!==void 0?this.setHex(n,e):Tt("Color: Unknown color "+t),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(t){return this.r=t.r,this.g=t.g,this.b=t.b,this}copySRGBToLinear(t){return this.r=Si(t.r),this.g=Si(t.g),this.b=Si(t.b),this}copyLinearToSRGB(t){return this.r=Qs(t.r),this.g=Qs(t.g),this.b=Qs(t.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(t=ee){return Ht.workingToColorSpace(rn.copy(this),t),Math.round(kt(rn.r*255,0,255))*65536+Math.round(kt(rn.g*255,0,255))*256+Math.round(kt(rn.b*255,0,255))}getHexString(t=ee){return("000000"+this.getHex(t).toString(16)).slice(-6)}getHSL(t,e=Ht.workingColorSpace){Ht.workingToColorSpace(rn.copy(this),e);let n=rn.r,i=rn.g,r=rn.b,o=Math.max(n,i,r),a=Math.min(n,i,r),c,l,h=(a+o)/2;if(a===o)c=0,l=0;else{let f=o-a;switch(l=h<=.5?f/(o+a):f/(2-o-a),o){case n:c=(i-r)/f+(i<r?6:0);break;case i:c=(r-n)/f+2;break;case r:c=(n-i)/f+4;break}c/=6}return t.h=c,t.s=l,t.l=h,t}getRGB(t,e=Ht.workingColorSpace){return Ht.workingToColorSpace(rn.copy(this),e),t.r=rn.r,t.g=rn.g,t.b=rn.b,t}getStyle(t=ee){Ht.workingToColorSpace(rn.copy(this),t);let e=rn.r,n=rn.g,i=rn.b;return t!==ee?`color(${t} ${e.toFixed(3)} ${n.toFixed(3)} ${i.toFixed(3)})`:`rgb(${Math.round(e*255)},${Math.round(n*255)},${Math.round(i*255)})`}offsetHSL(t,e,n){return this.getHSL(Hi),this.setHSL(Hi.h+t,Hi.s+e,Hi.l+n)}add(t){return this.r+=t.r,this.g+=t.g,this.b+=t.b,this}addColors(t,e){return this.r=t.r+e.r,this.g=t.g+e.g,this.b=t.b+e.b,this}addScalar(t){return this.r+=t,this.g+=t,this.b+=t,this}sub(t){return this.r=Math.max(0,this.r-t.r),this.g=Math.max(0,this.g-t.g),this.b=Math.max(0,this.b-t.b),this}multiply(t){return this.r*=t.r,this.g*=t.g,this.b*=t.b,this}multiplyScalar(t){return this.r*=t,this.g*=t,this.b*=t,this}lerp(t,e){return this.r+=(t.r-this.r)*e,this.g+=(t.g-this.g)*e,this.b+=(t.b-this.b)*e,this}lerpColors(t,e,n){return this.r=t.r+(e.r-t.r)*n,this.g=t.g+(e.g-t.g)*n,this.b=t.b+(e.b-t.b)*n,this}lerpHSL(t,e){this.getHSL(Hi),t.getHSL(aa);let n=eo(Hi.h,aa.h,e),i=eo(Hi.s,aa.s,e),r=eo(Hi.l,aa.l,e);return this.setHSL(n,i,r),this}setFromVector3(t){return this.r=t.x,this.g=t.y,this.b=t.z,this}applyMatrix3(t){let e=this.r,n=this.g,i=this.b,r=t.elements;return this.r=r[0]*e+r[3]*n+r[6]*i,this.g=r[1]*e+r[4]*n+r[7]*i,this.b=r[2]*e+r[5]*n+r[8]*i,this}equals(t){return t.r===this.r&&t.g===this.g&&t.b===this.b}fromArray(t,e=0){return this.r=t[e],this.g=t[e+1],this.b=t[e+2],this}toArray(t=[],e=0){return t[e]=this.r,t[e+1]=this.g,t[e+2]=this.b,t}fromBufferAttribute(t,e){return this.r=t.getX(e),this.g=t.getY(e),this.b=t.getZ(e),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}},rn=new Pt;Pt.NAMES=$d;var ro=class s{constructor(t,e=25e-5){this.isFogExp2=!0,this.name="",this.color=new Pt(t),this.density=e}clone(){return new s(this.color,this.density)}toJSON(){return{type:"FogExp2",name:this.name,color:this.color.getHex(),density:this.density}}};var oo=class extends Ae{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.backgroundRotation=new Ti,this.environmentIntensity=1,this.environmentRotation=new Ti,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(t,e){return super.copy(t,e),this.background=t.background!==null?t.background.clone():null,this.environment=t.environment!==null?t.environment.clone():null,this.fog=t.fog!==null?t.fog.clone():null,this.backgroundBlurriness=t.backgroundBlurriness,this.backgroundIntensity=t.backgroundIntensity,this.backgroundRotation.copy(t.backgroundRotation),this.environmentIntensity=t.environmentIntensity,this.environmentRotation.copy(t.environmentRotation),this.overrideMaterial=t.overrideMaterial!==null?t.overrideMaterial.clone():null,this.matrixAutoUpdate=t.matrixAutoUpdate,this}toJSON(t){let e=super.toJSON(t);return this.fog!==null&&(e.object.fog=this.fog.toJSON()),e.object.backgroundBlurriness=this.backgroundBlurriness,e.object.backgroundIntensity=this.backgroundIntensity,e.object.backgroundRotation=this.backgroundRotation.toArray(),e.object.environmentIntensity=this.environmentIntensity,e.object.environmentRotation=this.environmentRotation.toArray(),e}},Vn=new R,gi=new R,Vl=new R,_i=new R,Vs=new R,Gs=new R,Of=new R,Gl=new R,Hl=new R,Wl=new R,Xl=new Zt,ql=new Zt,Yl=new Zt,on=class s{constructor(t=new R,e=new R,n=new R){this.a=t,this.b=e,this.c=n}static getNormal(t,e,n,i){i.subVectors(n,e),Vn.subVectors(t,e),i.cross(Vn);let r=i.lengthSq();return r>0?i.multiplyScalar(1/Math.sqrt(r)):i.set(0,0,0)}static getBarycoord(t,e,n,i,r){Vn.subVectors(i,e),gi.subVectors(n,e),Vl.subVectors(t,e);let o=Vn.dot(Vn),a=Vn.dot(gi),c=Vn.dot(Vl),l=gi.dot(gi),h=gi.dot(Vl),f=o*l-a*a;if(f===0)return r.set(0,0,0),null;let u=1/f,d=(l*c-a*h)*u,g=(o*h-a*c)*u;return r.set(1-d-g,g,d)}static containsPoint(t,e,n,i){return this.getBarycoord(t,e,n,i,_i)===null?!1:_i.x>=0&&_i.y>=0&&_i.x+_i.y<=1}static getInterpolation(t,e,n,i,r,o,a,c){return this.getBarycoord(t,e,n,i,_i)===null?(c.x=0,c.y=0,"z"in c&&(c.z=0),"w"in c&&(c.w=0),null):(c.setScalar(0),c.addScaledVector(r,_i.x),c.addScaledVector(o,_i.y),c.addScaledVector(a,_i.z),c)}static getInterpolatedAttribute(t,e,n,i,r,o){return Xl.setScalar(0),ql.setScalar(0),Yl.setScalar(0),Xl.fromBufferAttribute(t,e),ql.fromBufferAttribute(t,n),Yl.fromBufferAttribute(t,i),o.setScalar(0),o.addScaledVector(Xl,r.x),o.addScaledVector(ql,r.y),o.addScaledVector(Yl,r.z),o}static isFrontFacing(t,e,n,i){return Vn.subVectors(n,e),gi.subVectors(t,e),Vn.cross(gi).dot(i)<0}set(t,e,n){return this.a.copy(t),this.b.copy(e),this.c.copy(n),this}setFromPointsAndIndices(t,e,n,i){return this.a.copy(t[e]),this.b.copy(t[n]),this.c.copy(t[i]),this}setFromAttributeAndIndices(t,e,n,i){return this.a.fromBufferAttribute(t,e),this.b.fromBufferAttribute(t,n),this.c.fromBufferAttribute(t,i),this}clone(){return new this.constructor().copy(this)}copy(t){return this.a.copy(t.a),this.b.copy(t.b),this.c.copy(t.c),this}getArea(){return Vn.subVectors(this.c,this.b),gi.subVectors(this.a,this.b),Vn.cross(gi).length()*.5}getMidpoint(t){return t.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(t){return s.getNormal(this.a,this.b,this.c,t)}getPlane(t){return t.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(t,e){return s.getBarycoord(t,this.a,this.b,this.c,e)}getInterpolation(t,e,n,i,r){return s.getInterpolation(t,this.a,this.b,this.c,e,n,i,r)}containsPoint(t){return s.containsPoint(t,this.a,this.b,this.c)}isFrontFacing(t){return s.isFrontFacing(this.a,this.b,this.c,t)}intersectsBox(t){return t.intersectsTriangle(this)}closestPointToPoint(t,e){let n=this.a,i=this.b,r=this.c,o,a;Vs.subVectors(i,n),Gs.subVectors(r,n),Gl.subVectors(t,n);let c=Vs.dot(Gl),l=Gs.dot(Gl);if(c<=0&&l<=0)return e.copy(n);Hl.subVectors(t,i);let h=Vs.dot(Hl),f=Gs.dot(Hl);if(h>=0&&f<=h)return e.copy(i);let u=c*f-h*l;if(u<=0&&c>=0&&h<=0&&c-h>0)return o=c/(c-h),e.copy(n).addScaledVector(Vs,o);Wl.subVectors(t,r);let d=Vs.dot(Wl),g=Gs.dot(Wl);if(g>=0&&d<=g)return e.copy(r);let v=d*l-c*g;if(v<=0&&l>=0&&g<=0)return a=l/(l-g),e.copy(n).addScaledVector(Gs,a);let m=h*g-d*f;if(m<=0&&f-h>=0&&d-g>=0)return Of.subVectors(r,i),a=(f-h)/(f-h+(d-g)),e.copy(i).addScaledVector(Of,a);let p=1/(m+v+u);return o=v*p,a=u*p,e.copy(n).addScaledVector(Vs,o).addScaledVector(Gs,a)}equals(t){return t.a.equals(this.a)&&t.b.equals(this.b)&&t.c.equals(this.c)}},Jt=class{constructor(t=new R(1/0,1/0,1/0),e=new R(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=t,this.max=e}set(t,e){return this.min.copy(t),this.max.copy(e),this}setFromArray(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e+=3)this.expandByPoint(Gn.fromArray(t,e));return this}setFromBufferAttribute(t){this.makeEmpty();for(let e=0,n=t.count;e<n;e++)this.expandByPoint(Gn.fromBufferAttribute(t,e));return this}setFromPoints(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e++)this.expandByPoint(t[e]);return this}setFromCenterAndSize(t,e){let n=Gn.copy(e).multiplyScalar(.5);return this.min.copy(t).sub(n),this.max.copy(t).add(n),this}setFromObject(t,e=!1){return this.makeEmpty(),this.expandByObject(t,e)}clone(){return new this.constructor().copy(this)}copy(t){return this.min.copy(t.min),this.max.copy(t.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(t){return this.isEmpty()?t.set(0,0,0):t.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(t){return this.isEmpty()?t.set(0,0,0):t.subVectors(this.max,this.min)}expandByPoint(t){return this.min.min(t),this.max.max(t),this}expandByVector(t){return this.min.sub(t),this.max.add(t),this}expandByScalar(t){return this.min.addScalar(-t),this.max.addScalar(t),this}expandByObject(t,e=!1){t.updateWorldMatrix(!1,!1);let n=t.geometry;if(n!==void 0){let r=n.getAttribute("position");if(e===!0&&r!==void 0&&t.isInstancedMesh!==!0&&t.isBatchedMesh!==!0)for(let o=0,a=r.count;o<a;o++)t.isMesh===!0?t.getVertexPosition(o,Gn):Gn.fromBufferAttribute(r,o),Gn.applyMatrix4(t.matrixWorld),this.expandByPoint(Gn);else t.boundingBox!==void 0?(t.boundingBox===null&&t.computeBoundingBox(),ca.copy(t.boundingBox)):(n.boundingBox===null&&n.computeBoundingBox(),ca.copy(n.boundingBox)),ca.applyMatrix4(t.matrixWorld),this.union(ca)}let i=t.children;for(let r=0,o=i.length;r<o;r++)this.expandByObject(i[r],e);return this}containsPoint(t){return t.x>=this.min.x&&t.x<=this.max.x&&t.y>=this.min.y&&t.y<=this.max.y&&t.z>=this.min.z&&t.z<=this.max.z}containsBox(t){return this.min.x<=t.min.x&&t.max.x<=this.max.x&&this.min.y<=t.min.y&&t.max.y<=this.max.y&&this.min.z<=t.min.z&&t.max.z<=this.max.z}getParameter(t,e){return e.set((t.x-this.min.x)/(this.max.x-this.min.x),(t.y-this.min.y)/(this.max.y-this.min.y),(t.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(t){return t.max.x>=this.min.x&&t.min.x<=this.max.x&&t.max.y>=this.min.y&&t.min.y<=this.max.y&&t.max.z>=this.min.z&&t.min.z<=this.max.z}intersectsSphere(t){return this.clampPoint(t.center,Gn),Gn.distanceToSquared(t.center)<=t.radius*t.radius}intersectsPlane(t){let e,n;return t.normal.x>0?(e=t.normal.x*this.min.x,n=t.normal.x*this.max.x):(e=t.normal.x*this.max.x,n=t.normal.x*this.min.x),t.normal.y>0?(e+=t.normal.y*this.min.y,n+=t.normal.y*this.max.y):(e+=t.normal.y*this.max.y,n+=t.normal.y*this.min.y),t.normal.z>0?(e+=t.normal.z*this.min.z,n+=t.normal.z*this.max.z):(e+=t.normal.z*this.max.z,n+=t.normal.z*this.min.z),e<=-t.constant&&n>=-t.constant}intersectsTriangle(t){if(this.isEmpty())return!1;this.getCenter(qr),la.subVectors(this.max,qr),Hs.subVectors(t.a,qr),Ws.subVectors(t.b,qr),Xs.subVectors(t.c,qr),Wi.subVectors(Ws,Hs),Xi.subVectors(Xs,Ws),hs.subVectors(Hs,Xs);let e=[0,-Wi.z,Wi.y,0,-Xi.z,Xi.y,0,-hs.z,hs.y,Wi.z,0,-Wi.x,Xi.z,0,-Xi.x,hs.z,0,-hs.x,-Wi.y,Wi.x,0,-Xi.y,Xi.x,0,-hs.y,hs.x,0];return!Kl(e,Hs,Ws,Xs,la)||(e=[1,0,0,0,1,0,0,0,1],!Kl(e,Hs,Ws,Xs,la))?!1:(ha.crossVectors(Wi,Xi),e=[ha.x,ha.y,ha.z],Kl(e,Hs,Ws,Xs,la))}clampPoint(t,e){return e.copy(t).clamp(this.min,this.max)}distanceToPoint(t){return this.clampPoint(t,Gn).distanceTo(t)}getBoundingSphere(t){return this.isEmpty()?t.makeEmpty():(this.getCenter(t.center),t.radius=this.getSize(Gn).length()*.5),t}intersect(t){return this.min.max(t.min),this.max.min(t.max),this.isEmpty()&&this.makeEmpty(),this}union(t){return this.min.min(t.min),this.max.max(t.max),this}applyMatrix4(t){return this.isEmpty()?this:(xi[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(t),xi[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(t),xi[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(t),xi[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(t),xi[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(t),xi[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(t),xi[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(t),xi[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(t),this.setFromPoints(xi),this)}translate(t){return this.min.add(t),this.max.add(t),this}equals(t){return t.min.equals(this.min)&&t.max.equals(this.max)}toJSON(){return{min:this.min.toArray(),max:this.max.toArray()}}fromJSON(t){return this.min.fromArray(t.min),this.max.fromArray(t.max),this}},xi=[new R,new R,new R,new R,new R,new R,new R,new R],Gn=new R,ca=new Jt,Hs=new R,Ws=new R,Xs=new R,Wi=new R,Xi=new R,hs=new R,qr=new R,la=new R,ha=new R,us=new R;function Kl(s,t,e,n,i){for(let r=0,o=s.length-3;r<=o;r+=3){us.fromArray(s,r);let a=i.x*Math.abs(us.x)+i.y*Math.abs(us.y)+i.z*Math.abs(us.z),c=t.dot(us),l=e.dot(us),h=n.dot(us);if(Math.max(-Math.max(c,l,h),Math.min(c,l,h))>a)return!1}return!0}var Mi=hg();function hg(){let s=new ArrayBuffer(4),t=new Float32Array(s),e=new Uint32Array(s),n=new Uint32Array(512),i=new Uint32Array(512);for(let c=0;c<256;++c){let l=c-127;l<-27?(n[c]=0,n[c|256]=32768,i[c]=24,i[c|256]=24):l<-14?(n[c]=1024>>-l-14,n[c|256]=1024>>-l-14|32768,i[c]=-l-1,i[c|256]=-l-1):l<=15?(n[c]=l+15<<10,n[c|256]=l+15<<10|32768,i[c]=13,i[c|256]=13):l<128?(n[c]=31744,n[c|256]=64512,i[c]=24,i[c|256]=24):(n[c]=31744,n[c|256]=64512,i[c]=13,i[c|256]=13)}let r=new Uint32Array(2048),o=new Uint32Array(64),a=new Uint32Array(64);for(let c=1;c<1024;++c){let l=c<<13,h=0;for(;(l&8388608)===0;)l<<=1,h-=8388608;l&=-8388609,h+=947912704,r[c]=l|h}for(let c=1024;c<2048;++c)r[c]=939524096+(c-1024<<13);for(let c=1;c<31;++c)o[c]=c<<23;o[31]=1199570944,o[32]=2147483648;for(let c=33;c<63;++c)o[c]=2147483648+(c-32<<23);o[63]=3347054592;for(let c=1;c<64;++c)c!==32&&(a[c]=1024);return{floatView:t,uint32View:e,baseTable:n,shiftTable:i,mantissaTable:r,exponentTable:o,offsetTable:a}}function ug(s){Math.abs(s)>65504&&Tt("DataUtils.toHalfFloat(): Value out of range."),s=kt(s,-65504,65504),Mi.floatView[0]=s;let t=Mi.uint32View[0],e=t>>23&511;return Mi.baseTable[e]+((t&8388607)>>Mi.shiftTable[e])}function fg(s){let t=s>>10;return Mi.uint32View[0]=Mi.mantissaTable[Mi.offsetTable[t]+(s&1023)]+Mi.exponentTable[t],Mi.floatView[0]}var xs=class{static toHalfFloat(t){return ug(t)}static fromHalfFloat(t){return fg(t)}},Fe=new R,ua=new At,dg=0,Te=class extends Qn{constructor(t,e,n=!1){if(super(),Array.isArray(t))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,Object.defineProperty(this,"id",{value:dg++}),this.name="",this.array=t,this.itemSize=e,this.count=t!==void 0?t.length/e:0,this.normalized=n,this.usage=Bh,this.updateRanges=[],this.gpuType=An,this.version=0,this._normalizationScale=t!==void 0?Hc(t):void 0}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.name=t.name,this.array=new t.array.constructor(t.array),this.itemSize=t.itemSize,this.count=t.count,this.normalized=t.normalized,this.usage=t.usage,this.gpuType=t.gpuType,this._normalizationScale=t._normalizationScale,this}copyAt(t,e,n){t*=this.itemSize,n*=e.itemSize;for(let i=0,r=this.itemSize;i<r;i++)this.array[t+i]=e.array[n+i];return this}copyArray(t){return this.array.set(t),this}applyMatrix3(t){if(this.itemSize===2)for(let e=0,n=this.count;e<n;e++)ua.fromBufferAttribute(this,e),ua.applyMatrix3(t),this.setXY(e,ua.x,ua.y);else if(this.itemSize===3)for(let e=0,n=this.count;e<n;e++)Fe.fromBufferAttribute(this,e),Fe.applyMatrix3(t),this.setXYZ(e,Fe.x,Fe.y,Fe.z);return this}applyMatrix4(t){for(let e=0,n=this.count;e<n;e++)Fe.fromBufferAttribute(this,e),Fe.applyMatrix4(t),this.setXYZ(e,Fe.x,Fe.y,Fe.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)Fe.fromBufferAttribute(this,e),Fe.applyNormalMatrix(t),this.setXYZ(e,Fe.x,Fe.y,Fe.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)Fe.fromBufferAttribute(this,e),Fe.transformDirection(t),this.setXYZ(e,Fe.x,Fe.y,Fe.z);return this}set(t,e=0){return this.array.set(t,e),this}getComponent(t,e){let n=this.array[t*this.itemSize+e];return this.normalized&&(n=this._denormalize(n)),n}setComponent(t,e,n){return this.normalized&&(n=this._normalize(n)),this.array[t*this.itemSize+e]=n,this}getX(t){let e=this.array[t*this.itemSize];return this.normalized&&(e=this._denormalize(e)),e}setX(t,e){return this.normalized&&(e=this._normalize(e)),this.array[t*this.itemSize]=e,this}getY(t){let e=this.array[t*this.itemSize+1];return this.normalized&&(e=this._denormalize(e)),e}setY(t,e){return this.normalized&&(e=this._normalize(e)),this.array[t*this.itemSize+1]=e,this}getZ(t){let e=this.array[t*this.itemSize+2];return this.normalized&&(e=this._denormalize(e)),e}setZ(t,e){return this.normalized&&(e=this._normalize(e)),this.array[t*this.itemSize+2]=e,this}getW(t){let e=this.array[t*this.itemSize+3];return this.normalized&&(e=this._denormalize(e)),e}setW(t,e){return this.normalized&&(e=this._normalize(e)),this.array[t*this.itemSize+3]=e,this}setXY(t,e,n){return t*=this.itemSize,this.normalized&&(e=this._normalize(e),n=this._normalize(n)),this.array[t+0]=e,this.array[t+1]=n,this}setXYZ(t,e,n,i){return t*=this.itemSize,this.normalized&&(e=this._normalize(e),n=this._normalize(n),i=this._normalize(i)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=i,this}setXYZW(t,e,n,i,r){return t*=this.itemSize,this.normalized&&(e=this._normalize(e),n=this._normalize(n),i=this._normalize(i),r=this._normalize(r)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=i,this.array[t+3]=r,this}onUpload(t){return this.onUploadCallback=t,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){let t={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return t.name=this.name,t.usage=this.usage,t.gpuType=this.gpuType,t}dispose(){this.dispatchEvent({type:"dispose"})}_denormalize(t){let e=this._normalizationScale;return e!==void 0?Math.max(t/e,-1):Gh(t,this.array)}_normalize(t){let e=this._normalizationScale;return e!==void 0?Math.round(t*e):Hh(t,this.array)}};var ao=class extends Te{constructor(t,e,n){super(new Uint16Array(t),e,n)}};var co=class extends Te{constructor(t,e,n){super(new Uint32Array(t),e,n)}};var ae=class extends Te{constructor(t,e,n){super(new Float32Array(t),e,n)}},pg=new Jt,Yr=new R,Zl=new R,yn=class{constructor(t=new R,e=-1){this.isSphere=!0,this.center=t,this.radius=e}set(t,e){return this.center.copy(t),this.radius=e,this}setFromPoints(t,e){let n=this.center;e!==void 0?n.copy(e):pg.setFromPoints(t).getCenter(n);let i=0;for(let r=0,o=t.length;r<o;r++)i=Math.max(i,n.distanceToSquared(t[r]));return this.radius=Math.sqrt(i),this}copy(t){return this.center.copy(t.center),this.radius=t.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(t){return t.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(t){return t.distanceTo(this.center)-this.radius}intersectsSphere(t){let e=this.radius+t.radius;return t.center.distanceToSquared(this.center)<=e*e}intersectsBox(t){return t.intersectsSphere(this)}intersectsPlane(t){return Math.abs(t.distanceToPoint(this.center))<=this.radius}clampPoint(t,e){let n=this.center.distanceToSquared(t);return e.copy(t),n>this.radius*this.radius&&(e.sub(this.center).normalize(),e.multiplyScalar(this.radius).add(this.center)),e}getBoundingBox(t){return this.isEmpty()?(t.makeEmpty(),t):(t.set(this.center,this.center),t.expandByScalar(this.radius),t)}applyMatrix4(t){return this.center.applyMatrix4(t),this.radius=this.radius*t.getMaxScaleOnAxis(),this}translate(t){return this.center.add(t),this}expandByPoint(t){if(this.isEmpty())return this.center.copy(t),this.radius=0,this;Yr.subVectors(t,this.center);let e=Yr.lengthSq();if(e>this.radius*this.radius){let n=Math.sqrt(e),i=(n-this.radius)*.5;this.center.addScaledVector(Yr,i/n),this.radius+=i}return this}union(t){return t.isEmpty()?this:this.isEmpty()?(this.copy(t),this):(this.center.equals(t.center)===!0?this.radius=Math.max(this.radius,t.radius):(Zl.subVectors(t.center,this.center).setLength(t.radius),this.expandByPoint(Yr.copy(t.center).add(Zl)),this.expandByPoint(Yr.copy(t.center).sub(Zl))),this)}equals(t){return t.center.equals(this.center)&&t.radius===this.radius}clone(){return new this.constructor().copy(this)}toJSON(){return{radius:this.radius,center:this.center.toArray()}}fromJSON(t){return this.radius=t.radius,this.center.fromArray(t.center),this}},mg=0,Nn=new _t,Jl=new Ae,qs=new R,Tn=new Jt,Kr=new Jt,qe=new R,ye=class s extends Qn{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:mg++}),this.uuid=oi(),this.name="",this.type="BufferGeometry",this.index=null,this.indirect=null,this.indirectOffset=0,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={},this._transformed=!1}getIndex(){return this.index}setIndex(t){return Array.isArray(t)?this.index=new(Om(t)?co:ao)(t,1):this.index=t,this}setIndirect(t,e=0){return this.indirect=t,this.indirectOffset=e,this}getIndirect(){return this.indirect}getAttribute(t){return this.attributes[t]}setAttribute(t,e){return this.attributes[t]=e,this}deleteAttribute(t){return delete this.attributes[t],this}hasAttribute(t){return this.attributes[t]!==void 0}addGroup(t,e,n=0){this.groups.push({start:t,count:e,materialIndex:n})}clearGroups(){this.groups=[]}setDrawRange(t,e){this.drawRange.start=t,this.drawRange.count=e}applyMatrix4(t){let e=this.attributes.position;e!==void 0&&(e.applyMatrix4(t),e.needsUpdate=!0);let n=this.attributes.normal;if(n!==void 0){let r=new Ft().getNormalMatrix(t);n.applyNormalMatrix(r),n.needsUpdate=!0}let i=this.attributes.tangent;return i!==void 0&&(i.transformDirection(t),i.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this._transformed=!0,this}applyQuaternion(t){return Nn.makeRotationFromQuaternion(t),this.applyMatrix4(Nn),this}rotateX(t){return Nn.makeRotationX(t),this.applyMatrix4(Nn),this}rotateY(t){return Nn.makeRotationY(t),this.applyMatrix4(Nn),this}rotateZ(t){return Nn.makeRotationZ(t),this.applyMatrix4(Nn),this}translate(t,e,n){return Nn.makeTranslation(t,e,n),this.applyMatrix4(Nn),this}scale(t,e,n){return Nn.makeScale(t,e,n),this.applyMatrix4(Nn),this}lookAt(t){return Jl.lookAt(t),Jl.updateMatrix(),this.applyMatrix4(Jl.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(qs).negate(),this.translate(qs.x,qs.y,qs.z),this}setFromPoints(t){let e=this.getAttribute("position");if(e===void 0){let n=[];for(let i=0,r=t.length;i<r;i++){let o=t[i];n.push(o.x,o.y,o.z||0)}this.setAttribute("position",new ae(n,3))}else{let n=Math.min(t.length,e.count);for(let i=0;i<n;i++){let r=t[i];e.setXYZ(i,r.x,r.y,r.z||0)}t.length>e.count&&Tt("BufferGeometry: Buffer size too small for points data. Use .dispose() and create a new geometry."),e.needsUpdate=!0}return this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new Jt);let t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){Dt("BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box.",this),this.boundingBox.set(new R(-1/0,-1/0,-1/0),new R(1/0,1/0,1/0));return}if(t!==void 0){if(this.boundingBox.setFromBufferAttribute(t),e)for(let n=0,i=e.length;n<i;n++){let r=e[n];Tn.setFromBufferAttribute(r),this.morphTargetsRelative?(qe.addVectors(this.boundingBox.min,Tn.min),this.boundingBox.expandByPoint(qe),qe.addVectors(this.boundingBox.max,Tn.max),this.boundingBox.expandByPoint(qe)):(this.boundingBox.expandByPoint(Tn.min),this.boundingBox.expandByPoint(Tn.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&Dt('BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new yn);let t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){Dt("BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere.",this),this.boundingSphere.set(new R,1/0);return}if(t){let n=this.boundingSphere.center;if(Tn.setFromBufferAttribute(t),e)for(let r=0,o=e.length;r<o;r++){let a=e[r];Kr.setFromBufferAttribute(a),this.morphTargetsRelative?(qe.addVectors(Tn.min,Kr.min),Tn.expandByPoint(qe),qe.addVectors(Tn.max,Kr.max),Tn.expandByPoint(qe)):(Tn.expandByPoint(Kr.min),Tn.expandByPoint(Kr.max))}Tn.getCenter(n);let i=0;for(let r=0,o=t.count;r<o;r++)qe.fromBufferAttribute(t,r),i=Math.max(i,n.distanceToSquared(qe));if(e)for(let r=0,o=e.length;r<o;r++){let a=e[r],c=this.morphTargetsRelative;for(let l=0,h=a.count;l<h;l++)qe.fromBufferAttribute(a,l),c&&(qs.fromBufferAttribute(t,l),qe.add(qs)),i=Math.max(i,n.distanceToSquared(qe))}this.boundingSphere.radius=Math.sqrt(i),isNaN(this.boundingSphere.radius)&&Dt('BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){let t=this.index,e=this.attributes;if(t===null||e.position===void 0||e.normal===void 0||e.uv===void 0){Dt("BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}let n=e.position,i=e.normal,r=e.uv,o=this.getAttribute("tangent");(o===void 0||o.count!==n.count)&&(o=new Te(new Float32Array(4*n.count),4),this.setAttribute("tangent",o));let a=[],c=[],l=new Uint8Array(n.count);for(let I=0;I<n.count;I++)a[I]=new R,c[I]=new R;let h=new R,f=new R,u=new R,d=new At,g=new At,v=new At,m=new R,p=new R;function x(I,E,L){l[I]=l[E]=l[L]=1,h.fromBufferAttribute(n,I),f.fromBufferAttribute(n,E),u.fromBufferAttribute(n,L),d.fromBufferAttribute(r,I),g.fromBufferAttribute(r,E),v.fromBufferAttribute(r,L),f.sub(h),u.sub(h),g.sub(d),v.sub(d);let C=1/(g.x*v.y-v.x*g.y);isFinite(C)&&(m.copy(f).multiplyScalar(v.y).addScaledVector(u,-g.y).multiplyScalar(C),p.copy(u).multiplyScalar(g.x).addScaledVector(f,-v.x).multiplyScalar(C),a[I].add(m),a[E].add(m),a[L].add(m),c[I].add(p),c[E].add(p),c[L].add(p))}let M=this.groups;M.length===0&&(M=[{start:0,count:t.count}]);for(let I=0,E=M.length;I<E;++I){let L=M[I],C=L.start,U=L.count;for(let N=C,B=C+U;N<B;N+=3)x(t.getX(N+0),t.getX(N+1),t.getX(N+2))}let y=new R,S=new R,T=new R,_=new R;function b(I){T.fromBufferAttribute(i,I),_.copy(T);let E=a[I];y.copy(E),y.sub(T.multiplyScalar(T.dot(E))).normalize(),S.crossVectors(_,E);let C=S.dot(c[I])<0?-1:1;o.setXYZW(I,y.x,y.y,y.z,C)}for(let I=0,E=n.count;I<E;++I)l[I]&&b(I);this._transformed=!0}computeVertexNormals(){let t=this.index,e=this.getAttribute("position");if(e!==void 0){let n=this.getAttribute("normal");if(n===void 0||n.count!==e.count)n=new Te(new Float32Array(e.count*3),3),this.setAttribute("normal",n);else for(let u=0,d=n.count;u<d;u++)n.setXYZ(u,0,0,0);let i=new R,r=new R,o=new R,a=new R,c=new R,l=new R,h=new R,f=new R;if(t)for(let u=0,d=t.count;u<d;u+=3){let g=t.getX(u+0),v=t.getX(u+1),m=t.getX(u+2);i.fromBufferAttribute(e,g),r.fromBufferAttribute(e,v),o.fromBufferAttribute(e,m),h.subVectors(o,r),f.subVectors(i,r),h.cross(f),a.fromBufferAttribute(n,g),c.fromBufferAttribute(n,v),l.fromBufferAttribute(n,m),a.add(h),c.add(h),l.add(h),n.setXYZ(g,a.x,a.y,a.z),n.setXYZ(v,c.x,c.y,c.z),n.setXYZ(m,l.x,l.y,l.z)}else for(let u=0,d=e.count;u<d;u+=3)i.fromBufferAttribute(e,u+0),r.fromBufferAttribute(e,u+1),o.fromBufferAttribute(e,u+2),h.subVectors(o,r),f.subVectors(i,r),h.cross(f),n.setXYZ(u+0,h.x,h.y,h.z),n.setXYZ(u+1,h.x,h.y,h.z),n.setXYZ(u+2,h.x,h.y,h.z);this.normalizeNormals(),n.needsUpdate=!0}}normalizeNormals(){let t=this.attributes.normal;for(let e=0,n=t.count;e<n;e++)qe.fromBufferAttribute(t,e),qe.normalize(),t.setXYZ(e,qe.x,qe.y,qe.z)}toNonIndexed(){function t(a,c){let l=a.array,h=a.itemSize,f=a.normalized,u=new l.constructor(c.length*h),d=0,g=0;for(let v=0,m=c.length;v<m;v++){a.isInterleavedBufferAttribute?d=c[v]*a.data.stride+a.offset:d=c[v]*h;for(let p=0;p<h;p++)u[g++]=l[d++]}return new Te(u,h,f)}if(this.index===null)return Tt("BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;let e=new s,n=this.index.array,i=this.attributes;for(let a in i){let c=i[a],l=t(c,n);e.setAttribute(a,l)}let r=this.morphAttributes;for(let a in r){let c=[],l=r[a];for(let h=0,f=l.length;h<f;h++){let u=l[h],d=t(u,n);c.push(d)}e.morphAttributes[a]=c}e.morphTargetsRelative=this.morphTargetsRelative;let o=this.groups;for(let a=0,c=o.length;a<c;a++){let l=o[a];e.addGroup(l.start,l.count,l.materialIndex)}return e}toJSON(){let t={metadata:{version:4.7,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(t.uuid=this.uuid,t.type=this.parameters!==void 0&&this._transformed===!0?"BufferGeometry":this.type,t.name=this.name,Object.keys(this.userData).length>0&&(t.userData=this.userData),this.parameters!==void 0&&this._transformed!==!0){let c=this.parameters;for(let l in c)c[l]!==void 0&&(t[l]=c[l]);return t}t.data={attributes:{}};let e=this.index;e!==null&&(t.data.index={type:e.array.constructor.name,array:Array.prototype.slice.call(e.array)});let n=this.attributes;for(let c in n){let l=n[c];t.data.attributes[c]=l.toJSON(t.data)}let i={},r=!1;for(let c in this.morphAttributes){let l=this.morphAttributes[c],h=[];for(let f=0,u=l.length;f<u;f++){let d=l[f];h.push(d.toJSON(t.data))}h.length>0&&(i[c]=h,r=!0)}r&&(t.data.morphAttributes=i,t.data.morphTargetsRelative=this.morphTargetsRelative);let o=this.groups;o.length>0&&(t.data.groups=JSON.parse(JSON.stringify(o)));let a=this.boundingSphere;return a!==null&&(t.data.boundingSphere=a.toJSON()),t}clone(){return new this.constructor().copy(this)}copy(t){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;let e={};this.name=t.name;let n=t.index;n!==null&&this.setIndex(n.clone());let i=t.attributes;for(let l in i){let h=i[l];this.setAttribute(l,h.clone(e))}let r=t.morphAttributes;for(let l in r){let h=[],f=r[l];for(let u=0,d=f.length;u<d;u++)h.push(f[u].clone(e));this.morphAttributes[l]=h}this.morphTargetsRelative=t.morphTargetsRelative;let o=t.groups;for(let l=0,h=o.length;l<h;l++){let f=o[l];this.addGroup(f.start,f.count,f.materialIndex)}let a=t.boundingBox;a!==null&&(this.boundingBox=a.clone());let c=t.boundingSphere;return c!==null&&(this.boundingSphere=c.clone()),this.drawRange.start=t.drawRange.start,this.drawRange.count=t.drawRange.count,this.userData=t.userData,this._transformed=t._transformed,this}dispose(){this.dispatchEvent({type:"dispose"})}},cr=class{constructor(t,e){this.isInterleavedBuffer=!0,this.array=t,this.stride=e,this.count=t!==void 0?t.length/e:0,this.usage=Bh,this.updateRanges=[],this.version=0,this.uuid=oi()}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.array=new t.array.constructor(t.array),this.count=t.count,this.stride=t.stride,this.usage=t.usage,this}copyAt(t,e,n){t*=this.stride,n*=e.stride;for(let i=0,r=this.stride;i<r;i++)this.array[t+i]=e.array[n+i];return this}set(t,e=0){return this.array.set(t,e),this}clone(t){t.arrayBuffers===void 0&&(t.arrayBuffers={});let e=Bf(this.array);t.arrayBuffers[e]===void 0&&(t.arrayBuffers[e]=this.array.slice(0).buffer);let n=new this.array.constructor(t.arrayBuffers[e]),i=new this.constructor(n,this.stride);return i.setUsage(this.usage),i}onUpload(t){return this.onUploadCallback=t,this}toJSON(t){t.arrayBuffers===void 0&&(t.arrayBuffers={});let e=Bf(this.array);t.arrayBuffers[e]===void 0&&(t.arrayBuffers[e]=Array.from(new Uint32Array(this.array.slice(0).buffer)));let n={uuid:this.uuid,buffer:e,type:this.array.constructor.name,stride:this.stride};return n.usage=this.usage,n}};function Bf(s){return s.buffer._uuid===void 0&&(s.buffer._uuid=oi()),s.byteOffset===0&&s.byteLength===s.buffer.byteLength?s.buffer._uuid:s.buffer._uuid+":"+s.byteOffset+":"+s.byteLength}var fn=new R,lr=class s{constructor(t,e,n,i=!1){this.isInterleavedBufferAttribute=!0,this.name="",this.data=t,this.itemSize=e,this.offset=n,this.normalized=i,this._normalizationScale=t!==void 0?Hc(t.array):void 0}get count(){return this.data.count}get array(){return this.data.array}set needsUpdate(t){this.data.needsUpdate=t}applyMatrix4(t){for(let e=0,n=this.data.count;e<n;e++)fn.fromBufferAttribute(this,e),fn.applyMatrix4(t),this.setXYZ(e,fn.x,fn.y,fn.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)fn.fromBufferAttribute(this,e),fn.applyNormalMatrix(t),this.setXYZ(e,fn.x,fn.y,fn.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)fn.fromBufferAttribute(this,e),fn.transformDirection(t),this.setXYZ(e,fn.x,fn.y,fn.z);return this}getComponent(t,e){let n=this.array[t*this.data.stride+this.offset+e];return this.normalized&&(n=this._denormalize(n)),n}setComponent(t,e,n){return this.normalized&&(n=this._normalize(n)),this.data.array[t*this.data.stride+this.offset+e]=n,this}setX(t,e){return this.normalized&&(e=this._normalize(e)),this.data.array[t*this.data.stride+this.offset]=e,this}setY(t,e){return this.normalized&&(e=this._normalize(e)),this.data.array[t*this.data.stride+this.offset+1]=e,this}setZ(t,e){return this.normalized&&(e=this._normalize(e)),this.data.array[t*this.data.stride+this.offset+2]=e,this}setW(t,e){return this.normalized&&(e=this._normalize(e)),this.data.array[t*this.data.stride+this.offset+3]=e,this}getX(t){let e=this.data.array[t*this.data.stride+this.offset];return this.normalized&&(e=this._denormalize(e)),e}getY(t){let e=this.data.array[t*this.data.stride+this.offset+1];return this.normalized&&(e=this._denormalize(e)),e}getZ(t){let e=this.data.array[t*this.data.stride+this.offset+2];return this.normalized&&(e=this._denormalize(e)),e}getW(t){let e=this.data.array[t*this.data.stride+this.offset+3];return this.normalized&&(e=this._denormalize(e)),e}setXY(t,e,n){return t=t*this.data.stride+this.offset,this.normalized&&(e=this._normalize(e),n=this._normalize(n)),this.data.array[t+0]=e,this.data.array[t+1]=n,this}setXYZ(t,e,n,i){return t=t*this.data.stride+this.offset,this.normalized&&(e=this._normalize(e),n=this._normalize(n),i=this._normalize(i)),this.data.array[t+0]=e,this.data.array[t+1]=n,this.data.array[t+2]=i,this}setXYZW(t,e,n,i,r){return t=t*this.data.stride+this.offset,this.normalized&&(e=this._normalize(e),n=this._normalize(n),i=this._normalize(i),r=this._normalize(r)),this.data.array[t+0]=e,this.data.array[t+1]=n,this.data.array[t+2]=i,this.data.array[t+3]=r,this}clone(t){if(t===void 0){io("InterleavedBufferAttribute.clone(): Cloning an interleaved buffer attribute will de-interleave buffer data.");let e=[];for(let n=0;n<this.count;n++){let i=n*this.data.stride+this.offset;for(let r=0;r<this.itemSize;r++)e.push(this.data.array[i+r])}return new Te(new this.array.constructor(e),this.itemSize,this.normalized)}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.clone(t)),new s(t.interleavedBuffers[this.data.uuid],this.itemSize,this.offset,this.normalized)}toJSON(t){if(t===void 0){io("InterleavedBufferAttribute.toJSON(): Serializing an interleaved buffer attribute will de-interleave buffer data.");let e=[];for(let n=0;n<this.count;n++){let i=n*this.data.stride+this.offset;for(let r=0;r<this.itemSize;r++)e.push(this.data.array[i+r])}return{itemSize:this.itemSize,type:this.array.constructor.name,array:e,normalized:this.normalized}}else return t.interleavedBuffers===void 0&&(t.interleavedBuffers={}),t.interleavedBuffers[this.data.uuid]===void 0&&(t.interleavedBuffers[this.data.uuid]=this.data.toJSON(t)),{isInterleavedBufferAttribute:!0,itemSize:this.itemSize,data:this.data.uuid,offset:this.offset,normalized:this.normalized}}_denormalize(t){let e=this._normalizationScale;return e!==void 0?Math.max(t/e,-1):Gh(t,this.data.array)}_normalize(t){let e=this._normalizationScale;return e!==void 0?Math.round(t*e):Hh(t,this.data.array)}},$l=new R,gg=new R,_g=new Ft,$e=class{constructor(t=new R(1,0,0),e=0){this.isPlane=!0,this.normal=t,this.constant=e}set(t,e){return this.normal.copy(t),this.constant=e,this}setComponents(t,e,n,i){return this.normal.set(t,e,n),this.constant=i,this}setFromNormalAndCoplanarPoint(t,e){return this.normal.copy(t),this.constant=-e.dot(this.normal),this}setFromCoplanarPoints(t,e,n){let i=$l.subVectors(n,e).cross(gg.subVectors(t,e)).normalize();return this.setFromNormalAndCoplanarPoint(i,t),this}copy(t){return this.normal.copy(t.normal),this.constant=t.constant,this}normalize(){let t=1/this.normal.length();return this.normal.multiplyScalar(t),this.constant*=t,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(t){return this.normal.dot(t)+this.constant}distanceToSphere(t){return this.distanceToPoint(t.center)-t.radius}projectPoint(t,e){return e.copy(t).addScaledVector(this.normal,-this.distanceToPoint(t))}intersectLine(t,e,n=!0){let i=t.delta($l),r=this.normal.dot(i);if(r===0)return this.distanceToPoint(t.start)===0?e.copy(t.start):null;let o=-(t.start.dot(this.normal)+this.constant)/r;return n===!0&&(o<0||o>1)?null:e.copy(t.start).addScaledVector(i,o)}intersectsLine(t){let e=this.distanceToPoint(t.start),n=this.distanceToPoint(t.end);return e<0&&n>0||n<0&&e>0}intersectsBox(t){return t.intersectsPlane(this)}intersectsSphere(t){return t.intersectsPlane(this)}coplanarPoint(t){return t.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(t,e){let n=e||_g.getNormalMatrix(t),i=this.coplanarPoint($l).applyMatrix4(t),r=this.normal.applyMatrix3(n).normalize();return this.constant=-i.dot(r),this}translate(t){return this.constant-=t.dot(this.normal),this}equals(t){return t.normal.equals(this.normal)&&t.constant===this.constant}clone(){return new this.constructor().copy(this)}toJSON(){return{normal:this.normal.toArray(),constant:this.constant}}fromJSON(t){return this.normal.fromArray(t.normal),this.constant=t.constant,this}},xg=0,vn=class extends Qn{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:xg++}),this.uuid=oi(),this.name="",this.type="Material",this.blending=yr,this.side=pn,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=Sh,this.blendDst=bh,this.blendEquation=ws,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new Pt(0,0,0),this.blendAlpha=0,this.depthFunc=tr,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=Vd,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=La,this.stencilZFail=La,this.stencilZPass=La,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.allowOverride=!0,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(t){this._alphaTest>0!=t>0&&this.version++,this._alphaTest=t}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(t){if(t!==void 0)for(let e in t){let n=t[e];if(n===void 0){Tt(`Material: parameter '${e}' has value of undefined.`);continue}let i=this[e];if(i===void 0){Tt(`Material: '${e}' is not a property of THREE.${this.type}.`);continue}i&&i.isColor?i.set(n):i&&i.isVector2&&n&&n.isVector2||i&&i.isEuler&&n&&n.isEuler||i&&i.isVector3&&n&&n.isVector3?i.copy(n):this[e]=n}}toJSON(t){let e=t===void 0||typeof t=="string";e&&(t={textures:{},images:{}});let n={metadata:{version:4.7,type:"Material",generator:"Material.toJSON"}};n.uuid=this.uuid,n.type=this.type,n.blending=this.blending,n.side=this.side,n.shadowSide=this.shadowSide,n.vertexColors=this.vertexColors,n.opacity=this.opacity,n.transparent=this.transparent,n.blendSrc=this.blendSrc,n.blendDst=this.blendDst,n.blendEquation=this.blendEquation,n.blendSrcAlpha=this.blendSrcAlpha,n.blendDstAlpha=this.blendDstAlpha,n.blendEquationAlpha=this.blendEquationAlpha,n.blendColor=this.blendColor.getHex(),n.blendAlpha=this.blendAlpha,n.depthFunc=this.depthFunc,n.depthTest=this.depthTest,n.depthWrite=this.depthWrite,n.colorWrite=this.colorWrite,n.clipIntersection=this.clipIntersection,n.clipShadows=this.clipShadows,n.stencilWriteMask=this.stencilWriteMask,n.stencilFunc=this.stencilFunc,n.stencilRef=this.stencilRef,n.stencilFuncMask=this.stencilFuncMask,n.stencilFail=this.stencilFail,n.stencilZFail=this.stencilZFail,n.stencilZPass=this.stencilZPass,n.stencilWrite=this.stencilWrite,n.polygonOffset=this.polygonOffset,n.polygonOffsetFactor=this.polygonOffsetFactor,n.polygonOffsetUnits=this.polygonOffsetUnits,n.dithering=this.dithering,n.alphaTest=this.alphaTest,n.alphaHash=this.alphaHash,n.alphaToCoverage=this.alphaToCoverage,n.premultipliedAlpha=this.premultipliedAlpha,n.forceSinglePass=this.forceSinglePass,n.allowOverride=this.allowOverride,n.visible=this.visible,n.toneMapped=this.toneMapped,n.name=this.name,this.color&&this.color.isColor&&(n.color=this.color.getHex()),this.roughness!==void 0&&(n.roughness=this.roughness),this.metalness!==void 0&&(n.metalness=this.metalness),this.sheen!==void 0&&(n.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(n.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(n.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(n.emissive=this.emissive.getHex()),this.emissiveIntensity!==void 0&&(n.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(n.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(n.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(n.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(n.shininess=this.shininess),this.clearcoat!==void 0&&(n.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(n.clearcoatRoughness=this.clearcoatRoughness),this.diffuseRoughness!==void 0&&(n.diffuseRoughness=this.diffuseRoughness),this.diffuseRoughnessMap&&this.diffuseRoughnessMap.isTexture&&(n.diffuseRoughnessMap=this.diffuseRoughnessMap.toJSON(t).uuid),this.clearcoatMap&&this.clearcoatMap.isTexture&&(n.clearcoatMap=this.clearcoatMap.toJSON(t).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(n.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(t).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(n.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(t).uuid,n.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.sheenColorMap&&this.sheenColorMap.isTexture&&(n.sheenColorMap=this.sheenColorMap.toJSON(t).uuid),this.sheenRoughnessMap&&this.sheenRoughnessMap.isTexture&&(n.sheenRoughnessMap=this.sheenRoughnessMap.toJSON(t).uuid),this.dispersion!==void 0&&(n.dispersion=this.dispersion),this.retroreflectivity!==void 0&&(n.retroreflectivity=this.retroreflectivity),this.iridescence!==void 0&&(n.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(n.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessMinimum!==void 0&&(n.iridescenceThicknessMinimum=this.iridescenceThicknessMinimum),this.iridescenceThicknessMaximum!==void 0&&(n.iridescenceThicknessMaximum=this.iridescenceThicknessMaximum),this.iridescenceMap&&this.iridescenceMap.isTexture&&(n.iridescenceMap=this.iridescenceMap.toJSON(t).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(n.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(t).uuid),this.anisotropy!==void 0&&(n.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(n.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(n.anisotropyMap=this.anisotropyMap.toJSON(t).uuid),this.map&&this.map.isTexture&&(n.map=this.map.toJSON(t).uuid),this.matcap&&this.matcap.isTexture&&(n.matcap=this.matcap.toJSON(t).uuid),this.alphaMap&&this.alphaMap.isTexture&&(n.alphaMap=this.alphaMap.toJSON(t).uuid),this.lightMap&&this.lightMap.isTexture&&(n.lightMap=this.lightMap.toJSON(t).uuid,n.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(n.aoMap=this.aoMap.toJSON(t).uuid,n.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(n.bumpMap=this.bumpMap.toJSON(t).uuid,n.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(n.normalMap=this.normalMap.toJSON(t).uuid,n.normalMapType=this.normalMapType,n.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(n.displacementMap=this.displacementMap.toJSON(t).uuid,n.displacementScale=this.displacementScale,n.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(n.roughnessMap=this.roughnessMap.toJSON(t).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(n.metalnessMap=this.metalnessMap.toJSON(t).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(n.emissiveMap=this.emissiveMap.toJSON(t).uuid),this.specularMap&&this.specularMap.isTexture&&(n.specularMap=this.specularMap.toJSON(t).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(n.specularIntensityMap=this.specularIntensityMap.toJSON(t).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(n.specularColorMap=this.specularColorMap.toJSON(t).uuid),this.envMap&&this.envMap.isTexture&&(n.envMap=this.envMap.toJSON(t).uuid,this.combine!==void 0&&(n.combine=this.combine)),this.envMapRotation!==void 0&&(n.envMapRotation=this.envMapRotation.toArray()),this.envMapIntensity!==void 0&&(n.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(n.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(n.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(n.gradientMap=this.gradientMap.toJSON(t).uuid),this.transmission!==void 0&&(n.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(n.transmissionMap=this.transmissionMap.toJSON(t).uuid),this.thickness!==void 0&&(n.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(n.thicknessMap=this.thicknessMap.toJSON(t).uuid),this.attenuationDistance!==void 0&&(n.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(n.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(n.size=this.size),this.sizeAttenuation!==void 0&&(n.sizeAttenuation=this.sizeAttenuation),Array.isArray(this.clippingPlanes)&&this.clippingPlanes.length>0&&(n.clippingPlanes=this.clippingPlanes.map(r=>r.toJSON())),this.rotation!==void 0&&(n.rotation=this.rotation),this.depthPacking!==void 0&&(n.depthPacking=this.depthPacking),this.linewidth!==void 0&&(n.linewidth=this.linewidth),this.linecap!==void 0&&(n.linecap=this.linecap),this.linejoin!==void 0&&(n.linejoin=this.linejoin),this.dashSize!==void 0&&(n.dashSize=this.dashSize),this.gapSize!==void 0&&(n.gapSize=this.gapSize),this.scale!==void 0&&(n.scale=this.scale),this.wireframe!==void 0&&(n.wireframe=this.wireframe),this.wireframeLinewidth!==void 0&&(n.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!==void 0&&(n.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!==void 0&&(n.wireframeLinejoin=this.wireframeLinejoin),this.flatShading!==void 0&&(n.flatShading=this.flatShading),this.fog!==void 0&&(n.fog=this.fog),Object.keys(this.userData).length>0&&(n.userData=this.userData);function i(r){let o=[];for(let a in r){let c=r[a];delete c.metadata,o.push(c)}return o}if(e){let r=i(t.textures),o=i(t.images);r.length>0&&(n.textures=r),o.length>0&&(n.images=o)}return n}fromJSON(t,e){if(t.uuid!==void 0&&(this.uuid=t.uuid),t.name!==void 0&&(this.name=t.name),t.color!==void 0&&this.color!==void 0&&this.color.setHex(t.color),t.roughness!==void 0&&(this.roughness=t.roughness),t.metalness!==void 0&&(this.metalness=t.metalness),t.sheen!==void 0&&(this.sheen=t.sheen),t.sheenColor!==void 0&&(this.sheenColor=new Pt().setHex(t.sheenColor)),t.sheenRoughness!==void 0&&(this.sheenRoughness=t.sheenRoughness),t.emissive!==void 0&&this.emissive!==void 0&&this.emissive.setHex(t.emissive),t.specular!==void 0&&this.specular!==void 0&&this.specular.setHex(t.specular),t.specularIntensity!==void 0&&(this.specularIntensity=t.specularIntensity),t.specularColor!==void 0&&this.specularColor!==void 0&&this.specularColor.setHex(t.specularColor),t.shininess!==void 0&&(this.shininess=t.shininess),t.clearcoat!==void 0&&(this.clearcoat=t.clearcoat),t.clearcoatRoughness!==void 0&&(this.clearcoatRoughness=t.clearcoatRoughness),t.diffuseRoughness!==void 0&&(this.diffuseRoughness=t.diffuseRoughness),t.dispersion!==void 0&&(this.dispersion=t.dispersion),t.retroreflectivity!==void 0&&(this.retroreflectivity=t.retroreflectivity),t.iridescence!==void 0&&(this.iridescence=t.iridescence),t.iridescenceIOR!==void 0&&(this.iridescenceIOR=t.iridescenceIOR),t.iridescenceThicknessMinimum!==void 0&&(this.iridescenceThicknessMinimum=t.iridescenceThicknessMinimum),t.iridescenceThicknessMaximum!==void 0&&(this.iridescenceThicknessMaximum=t.iridescenceThicknessMaximum),t.iridescenceThicknessRange!==void 0&&(this.iridescenceThicknessMinimum=t.iridescenceThicknessRange[0],this.iridescenceThicknessMaximum=t.iridescenceThicknessRange[1]),t.transmission!==void 0&&(this.transmission=t.transmission),t.thickness!==void 0&&(this.thickness=t.thickness),t.attenuationDistance!==void 0&&(this.attenuationDistance=t.attenuationDistance),t.attenuationColor!==void 0&&this.attenuationColor!==void 0&&this.attenuationColor.setHex(t.attenuationColor),t.anisotropy!==void 0&&(this.anisotropy=t.anisotropy),t.anisotropyRotation!==void 0&&(this.anisotropyRotation=t.anisotropyRotation),t.fog!==void 0&&(this.fog=t.fog),t.flatShading!==void 0&&(this.flatShading=t.flatShading),t.blending!==void 0&&(this.blending=t.blending),t.combine!==void 0&&(this.combine=t.combine),t.side!==void 0&&(this.side=t.side),t.shadowSide!==void 0&&(this.shadowSide=t.shadowSide),t.opacity!==void 0&&(this.opacity=t.opacity),t.transparent!==void 0&&(this.transparent=t.transparent),t.alphaTest!==void 0&&(this.alphaTest=t.alphaTest),t.alphaHash!==void 0&&(this.alphaHash=t.alphaHash),t.depthFunc!==void 0&&(this.depthFunc=t.depthFunc),t.depthTest!==void 0&&(this.depthTest=t.depthTest),t.depthWrite!==void 0&&(this.depthWrite=t.depthWrite),t.colorWrite!==void 0&&(this.colorWrite=t.colorWrite),t.clippingPlanes!==void 0&&(this.clippingPlanes=t.clippingPlanes.map(n=>new $e().fromJSON(n))),t.clipIntersection!==void 0&&(this.clipIntersection=t.clipIntersection),t.clipShadows!==void 0&&(this.clipShadows=t.clipShadows),t.depthPacking!==void 0&&(this.depthPacking=t.depthPacking),t.blendSrc!==void 0&&(this.blendSrc=t.blendSrc),t.blendDst!==void 0&&(this.blendDst=t.blendDst),t.blendEquation!==void 0&&(this.blendEquation=t.blendEquation),t.blendSrcAlpha!==void 0&&(this.blendSrcAlpha=t.blendSrcAlpha),t.blendDstAlpha!==void 0&&(this.blendDstAlpha=t.blendDstAlpha),t.blendEquationAlpha!==void 0&&(this.blendEquationAlpha=t.blendEquationAlpha),t.blendColor!==void 0&&this.blendColor!==void 0&&this.blendColor.setHex(t.blendColor),t.blendAlpha!==void 0&&(this.blendAlpha=t.blendAlpha),t.stencilWriteMask!==void 0&&(this.stencilWriteMask=t.stencilWriteMask),t.stencilFunc!==void 0&&(this.stencilFunc=t.stencilFunc),t.stencilRef!==void 0&&(this.stencilRef=t.stencilRef),t.stencilFuncMask!==void 0&&(this.stencilFuncMask=t.stencilFuncMask),t.stencilFail!==void 0&&(this.stencilFail=t.stencilFail),t.stencilZFail!==void 0&&(this.stencilZFail=t.stencilZFail),t.stencilZPass!==void 0&&(this.stencilZPass=t.stencilZPass),t.stencilWrite!==void 0&&(this.stencilWrite=t.stencilWrite),t.wireframe!==void 0&&(this.wireframe=t.wireframe),t.wireframeLinewidth!==void 0&&(this.wireframeLinewidth=t.wireframeLinewidth),t.wireframeLinecap!==void 0&&(this.wireframeLinecap=t.wireframeLinecap),t.wireframeLinejoin!==void 0&&(this.wireframeLinejoin=t.wireframeLinejoin),t.rotation!==void 0&&(this.rotation=t.rotation),t.linewidth!==void 0&&(this.linewidth=t.linewidth),t.linecap!==void 0&&(this.linecap=t.linecap),t.linejoin!==void 0&&(this.linejoin=t.linejoin),t.dashSize!==void 0&&(this.dashSize=t.dashSize),t.gapSize!==void 0&&(this.gapSize=t.gapSize),t.scale!==void 0&&(this.scale=t.scale),t.polygonOffset!==void 0&&(this.polygonOffset=t.polygonOffset),t.polygonOffsetFactor!==void 0&&(this.polygonOffsetFactor=t.polygonOffsetFactor),t.polygonOffsetUnits!==void 0&&(this.polygonOffsetUnits=t.polygonOffsetUnits),t.dithering!==void 0&&(this.dithering=t.dithering),t.alphaToCoverage!==void 0&&(this.alphaToCoverage=t.alphaToCoverage),t.premultipliedAlpha!==void 0&&(this.premultipliedAlpha=t.premultipliedAlpha),t.forceSinglePass!==void 0&&(this.forceSinglePass=t.forceSinglePass),t.allowOverride!==void 0&&(this.allowOverride=t.allowOverride),t.visible!==void 0&&(this.visible=t.visible),t.toneMapped!==void 0&&(this.toneMapped=t.toneMapped),t.userData!==void 0&&(this.userData=t.userData),t.vertexColors!==void 0&&(typeof t.vertexColors=="number"?this.vertexColors=t.vertexColors>0:this.vertexColors=t.vertexColors),t.size!==void 0&&(this.size=t.size),t.sizeAttenuation!==void 0&&(this.sizeAttenuation=t.sizeAttenuation),t.map!==void 0&&(this.map=e[t.map]||null),t.matcap!==void 0&&(this.matcap=e[t.matcap]||null),t.alphaMap!==void 0&&(this.alphaMap=e[t.alphaMap]||null),t.bumpMap!==void 0&&(this.bumpMap=e[t.bumpMap]||null),t.bumpScale!==void 0&&(this.bumpScale=t.bumpScale),t.normalMap!==void 0&&(this.normalMap=e[t.normalMap]||null),t.normalMapType!==void 0&&(this.normalMapType=t.normalMapType),t.normalScale!==void 0){let n=t.normalScale;Array.isArray(n)===!1&&(n=[n,n]),this.normalScale=new At().fromArray(n)}return t.displacementMap!==void 0&&(this.displacementMap=e[t.displacementMap]||null),t.displacementScale!==void 0&&(this.displacementScale=t.displacementScale),t.displacementBias!==void 0&&(this.displacementBias=t.displacementBias),t.roughnessMap!==void 0&&(this.roughnessMap=e[t.roughnessMap]||null),t.metalnessMap!==void 0&&(this.metalnessMap=e[t.metalnessMap]||null),t.emissiveMap!==void 0&&(this.emissiveMap=e[t.emissiveMap]||null),t.emissiveIntensity!==void 0&&(this.emissiveIntensity=t.emissiveIntensity),t.specularMap!==void 0&&(this.specularMap=e[t.specularMap]||null),t.specularIntensityMap!==void 0&&(this.specularIntensityMap=e[t.specularIntensityMap]||null),t.specularColorMap!==void 0&&(this.specularColorMap=e[t.specularColorMap]||null),t.envMap!==void 0&&(this.envMap=e[t.envMap]||null),t.envMapRotation!==void 0&&this.envMapRotation.fromArray(t.envMapRotation),t.envMapIntensity!==void 0&&(this.envMapIntensity=t.envMapIntensity),t.reflectivity!==void 0&&(this.reflectivity=t.reflectivity),t.refractionRatio!==void 0&&(this.refractionRatio=t.refractionRatio),t.lightMap!==void 0&&(this.lightMap=e[t.lightMap]||null),t.lightMapIntensity!==void 0&&(this.lightMapIntensity=t.lightMapIntensity),t.aoMap!==void 0&&(this.aoMap=e[t.aoMap]||null),t.aoMapIntensity!==void 0&&(this.aoMapIntensity=t.aoMapIntensity),t.gradientMap!==void 0&&(this.gradientMap=e[t.gradientMap]||null),t.clearcoatMap!==void 0&&(this.clearcoatMap=e[t.clearcoatMap]||null),t.clearcoatRoughnessMap!==void 0&&(this.clearcoatRoughnessMap=e[t.clearcoatRoughnessMap]||null),t.clearcoatNormalMap!==void 0&&(this.clearcoatNormalMap=e[t.clearcoatNormalMap]||null),t.clearcoatNormalScale!==void 0&&(this.clearcoatNormalScale=new At().fromArray(t.clearcoatNormalScale)),t.diffuseRoughnessMap!==void 0&&(this.diffuseRoughnessMap=e[t.diffuseRoughnessMap]||null),t.iridescenceMap!==void 0&&(this.iridescenceMap=e[t.iridescenceMap]||null),t.iridescenceThicknessMap!==void 0&&(this.iridescenceThicknessMap=e[t.iridescenceThicknessMap]||null),t.transmissionMap!==void 0&&(this.transmissionMap=e[t.transmissionMap]||null),t.thicknessMap!==void 0&&(this.thicknessMap=e[t.thicknessMap]||null),t.anisotropyMap!==void 0&&(this.anisotropyMap=e[t.anisotropyMap]||null),t.sheenColorMap!==void 0&&(this.sheenColorMap=e[t.sheenColorMap]||null),t.sheenRoughnessMap!==void 0&&(this.sheenRoughnessMap=e[t.sheenRoughnessMap]||null),this}clone(){return new this.constructor().copy(this)}copy(t){this.name=t.name,this.blending=t.blending,this.side=t.side,this.vertexColors=t.vertexColors,this.opacity=t.opacity,this.transparent=t.transparent,this.blendSrc=t.blendSrc,this.blendDst=t.blendDst,this.blendEquation=t.blendEquation,this.blendSrcAlpha=t.blendSrcAlpha,this.blendDstAlpha=t.blendDstAlpha,this.blendEquationAlpha=t.blendEquationAlpha,this.blendColor.copy(t.blendColor),this.blendAlpha=t.blendAlpha,this.depthFunc=t.depthFunc,this.depthTest=t.depthTest,this.depthWrite=t.depthWrite,this.stencilWriteMask=t.stencilWriteMask,this.stencilFunc=t.stencilFunc,this.stencilRef=t.stencilRef,this.stencilFuncMask=t.stencilFuncMask,this.stencilFail=t.stencilFail,this.stencilZFail=t.stencilZFail,this.stencilZPass=t.stencilZPass,this.stencilWrite=t.stencilWrite;let e=t.clippingPlanes,n=null;if(e!==null){let i=e.length;n=new Array(i);for(let r=0;r!==i;++r)n[r]=e[r].clone()}return this.clippingPlanes=n,this.clipIntersection=t.clipIntersection,this.clipShadows=t.clipShadows,this.shadowSide=t.shadowSide,this.colorWrite=t.colorWrite,this.precision=t.precision,this.polygonOffset=t.polygonOffset,this.polygonOffsetFactor=t.polygonOffsetFactor,this.polygonOffsetUnits=t.polygonOffsetUnits,this.dithering=t.dithering,this.alphaTest=t.alphaTest,this.alphaHash=t.alphaHash,this.alphaToCoverage=t.alphaToCoverage,this.premultipliedAlpha=t.premultipliedAlpha,this.forceSinglePass=t.forceSinglePass,this.allowOverride=t.allowOverride,this.visible=t.visible,this.toneMapped=t.toneMapped,this.userData=JSON.parse(JSON.stringify(t.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(t){t===!0&&this.version++}};var yi=new R,jl=new R,fa=new R,da=new R,ti=class{constructor(t=new R,e=new R(0,0,-1)){this.origin=t,this.direction=e}set(t,e){return this.origin.copy(t),this.direction.copy(e),this}copy(t){return this.origin.copy(t.origin),this.direction.copy(t.direction),this}at(t,e){return e.copy(this.origin).addScaledVector(this.direction,t)}lookAt(t){return this.direction.copy(t).sub(this.origin).normalize(),this}recast(t){return this.origin.copy(this.at(t,yi)),this}closestPointToPoint(t,e){e.subVectors(t,this.origin);let n=e.dot(this.direction);return n<0?e.copy(this.origin):e.copy(this.origin).addScaledVector(this.direction,n)}distanceToPoint(t){return Math.sqrt(this.distanceSqToPoint(t))}distanceSqToPoint(t){let e=yi.subVectors(t,this.origin).dot(this.direction);return e<0?this.origin.distanceToSquared(t):(yi.copy(this.origin).addScaledVector(this.direction,e),yi.distanceToSquared(t))}distanceSqToSegment(t,e,n,i){jl.copy(t).add(e).multiplyScalar(.5),fa.copy(e).sub(t).normalize(),da.copy(this.origin).sub(jl);let r=t.distanceTo(e)*.5,o=-this.direction.dot(fa),a=da.dot(this.direction),c=-da.dot(fa),l=da.lengthSq(),h=Math.abs(1-o*o),f,u,d,g;if(h>0)if(f=o*c-a,u=o*a-c,g=r*h,f>=0)if(u>=-g)if(u<=g){let v=1/h;f*=v,u*=v,d=f*(f+o*u+2*a)+u*(o*f+u+2*c)+l}else u=r,f=Math.max(0,-(o*u+a)),d=-f*f+u*(u+2*c)+l;else u=-r,f=Math.max(0,-(o*u+a)),d=-f*f+u*(u+2*c)+l;else u<=-g?(f=Math.max(0,-(-o*r+a)),u=f>0?-r:Math.min(Math.max(-r,-c),r),d=-f*f+u*(u+2*c)+l):u<=g?(f=0,u=Math.min(Math.max(-r,-c),r),d=u*(u+2*c)+l):(f=Math.max(0,-(o*r+a)),u=f>0?r:Math.min(Math.max(-r,-c),r),d=-f*f+u*(u+2*c)+l);else u=o>0?-r:r,f=Math.max(0,-(o*u+a)),d=-f*f+u*(u+2*c)+l;return n&&n.copy(this.origin).addScaledVector(this.direction,f),i&&i.copy(jl).addScaledVector(fa,u),d}intersectSphere(t,e){if(t.radius<0)return null;yi.subVectors(t.center,this.origin);let n=yi.dot(this.direction),i=yi.dot(yi)-n*n,r=t.radius*t.radius;if(i>r)return null;let o=Math.sqrt(r-i),a=n-o,c=n+o;return c<0?null:a<0?this.at(c,e):this.at(a,e)}intersectsSphere(t){return t.radius<0?!1:this.distanceSqToPoint(t.center)<=t.radius*t.radius}distanceToPlane(t){let e=t.normal.dot(this.direction);if(e===0)return t.distanceToPoint(this.origin)===0?0:null;let n=-(this.origin.dot(t.normal)+t.constant)/e;return n>=0?n:null}intersectPlane(t,e){let n=this.distanceToPlane(t);return n===null?null:this.at(n,e)}intersectsPlane(t){let e=t.distanceToPoint(this.origin);return e===0||t.normal.dot(this.direction)*e<0}intersectBox(t,e){let n,i,r,o,a,c,l=1/this.direction.x,h=1/this.direction.y,f=1/this.direction.z,u=this.origin;return l>=0?(n=(t.min.x-u.x)*l,i=(t.max.x-u.x)*l):(n=(t.max.x-u.x)*l,i=(t.min.x-u.x)*l),h>=0?(r=(t.min.y-u.y)*h,o=(t.max.y-u.y)*h):(r=(t.max.y-u.y)*h,o=(t.min.y-u.y)*h),n>o||r>i||((r>n||isNaN(n))&&(n=r),(o<i||isNaN(i))&&(i=o),f>=0?(a=(t.min.z-u.z)*f,c=(t.max.z-u.z)*f):(a=(t.max.z-u.z)*f,c=(t.min.z-u.z)*f),n>c||a>i)||((a>n||n!==n)&&(n=a),(c<i||i!==i)&&(i=c),i<0)?null:this.at(n>=0?n:i,e)}intersectsBox(t){return this.intersectBox(t,yi)!==null}intersectTriangle(t,e,n,i,r){let o=this.origin,a=this.direction,c=a.x,l=a.y,h=a.z,f=t.x-o.x,u=t.y-o.y,d=t.z-o.z,g=e.x-o.x,v=e.y-o.y,m=e.z-o.z,p=n.x-o.x,x=n.y-o.y,M=n.z-o.z,y=Math.abs(c),S=Math.abs(l),T=Math.abs(h),_,b,I,E,L,C,U,N,B,G,H,tt;if(y>=S&&y>=T?(I=c,C=f,B=g,tt=p,c>=0?(_=l,b=h,E=u,L=d,U=v,N=m,G=x,H=M):(_=h,b=l,E=d,L=u,U=m,N=v,G=M,H=x)):S>=T?(I=l,C=u,B=v,tt=x,l>=0?(_=h,b=c,E=d,L=f,U=m,N=g,G=M,H=p):(_=c,b=h,E=f,L=d,U=g,N=m,G=p,H=M)):(I=h,C=d,B=m,tt=M,h>=0?(_=c,b=l,E=f,L=u,U=g,N=v,G=p,H=x):(_=l,b=c,E=u,L=f,U=v,N=g,G=x,H=p)),I===0)return null;let X=_/I,j=b/I,Q=1/I,yt=E-X*C,Ut=L-j*C,Z=U-X*B,lt=N-j*B,xt=G-X*tt,Ct=H-j*tt,dt=xt*lt-Ct*Z,Ot=yt*Ct-Ut*xt,Ce=Z*Ut-lt*yt;if(i){if(dt<0||Ot<0||Ce<0)return null}else if((dt<0||Ot<0||Ce<0)&&(dt>0||Ot>0||Ce>0))return null;let It=dt+Ot+Ce;if(It===0)return null;let jt=Q*(dt*C+Ot*B+Ce*tt);return(It>0?jt<0:jt>0)?null:this.at(jt/It,r)}applyMatrix4(t){return this.origin.applyMatrix4(t),this.direction.transformDirection(t),this}equals(t){return t.origin.equals(this.origin)&&t.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}},Oe=class extends vn{constructor(t){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new Pt(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Ti,this.combine=Th,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.specularMap=t.specularMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapRotation.copy(t.envMapRotation),this.combine=t.combine,this.reflectivity=t.reflectivity,this.refractionRatio=t.refractionRatio,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.fog=t.fog,this}},zf=new _t,fs=new ti,pa=new yn,kf=new R,ma=new R,ga=new R,_a=new R,Ql=new R,xa=new R,Vf=new R,ya=new R,Ee=class extends Ae{constructor(t=new ye,e=new Oe){super(),this.isMesh=!0,this.type="Mesh",this.geometry=t,this.material=e,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.count=1,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0?this.morphTargetInfluences=t.morphTargetInfluences.slice():this.morphTargetInfluences=void 0,t.morphTargetDictionary!==void 0?this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary):this.morphTargetDictionary=void 0,this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}updateMorphTargets(){let e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){let i=e[n[0]];if(i!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,o=i.length;r<o;r++){let a=i[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=r}}}}getVertexPosition(t,e){let n=this.geometry,i=n.attributes.position,r=n.morphAttributes.position,o=n.morphTargetsRelative;e.fromBufferAttribute(i,t);let a=this.morphTargetInfluences;if(r&&a){xa.set(0,0,0);for(let c=0,l=r.length;c<l;c++){let h=a[c],f=r[c];h!==0&&(Ql.fromBufferAttribute(f,t),o?xa.addScaledVector(Ql,h):xa.addScaledVector(Ql.sub(e),h))}e.add(xa)}return e}intersectsFrustum(t){return t.intersectsObject(this)}raycast(t,e){let n=this.geometry,i=this.material,r=this.matrixWorld;i!==void 0&&(n.boundingSphere===null&&n.computeBoundingSphere(),pa.copy(n.boundingSphere),pa.applyMatrix4(r),fs.copy(t.ray).recast(t.near),!(pa.containsPoint(fs.origin)===!1&&(fs.intersectSphere(pa,kf)===null||fs.origin.distanceToSquared(kf)>(t.far-t.near)**2))&&(zf.copy(r).invert(),fs.copy(t.ray).applyMatrix4(zf),!(n.boundingBox!==null&&fs.intersectsBox(n.boundingBox)===!1)&&this._computeIntersections(t,e,fs)))}_computeIntersections(t,e,n){let i,r=this.geometry,o=this.material,a=r.index,c=r.attributes.position,l=r.attributes.uv,h=r.attributes.uv1,f=r.attributes.normal,u=r.groups,d=r.drawRange;if(a!==null)if(Array.isArray(o))for(let g=0,v=u.length;g<v;g++){let m=u[g],p=o[m.materialIndex],x=Math.max(m.start,d.start),M=Math.min(a.count,Math.min(m.start+m.count,d.start+d.count));for(let y=x,S=M;y<S;y+=3){let T=a.getX(y),_=a.getX(y+1),b=a.getX(y+2);i=va(this,p,t,n,l,h,f,T,_,b),i&&(i.faceIndex=Math.floor(y/3),i.face.materialIndex=m.materialIndex,e.push(i))}}else{let g=Math.max(0,d.start),v=Math.min(a.count,d.start+d.count);for(let m=g,p=v;m<p;m+=3){let x=a.getX(m),M=a.getX(m+1),y=a.getX(m+2);i=va(this,o,t,n,l,h,f,x,M,y),i&&(i.faceIndex=Math.floor(m/3),e.push(i))}}else if(c!==void 0)if(Array.isArray(o))for(let g=0,v=u.length;g<v;g++){let m=u[g],p=o[m.materialIndex],x=Math.max(m.start,d.start),M=Math.min(c.count,Math.min(m.start+m.count,d.start+d.count));for(let y=x,S=M;y<S;y+=3){let T=y,_=y+1,b=y+2;i=va(this,p,t,n,l,h,f,T,_,b),i&&(i.faceIndex=Math.floor(y/3),i.face.materialIndex=m.materialIndex,e.push(i))}}else{let g=Math.max(0,d.start),v=Math.min(c.count,d.start+d.count);for(let m=g,p=v;m<p;m+=3){let x=m,M=m+1,y=m+2;i=va(this,o,t,n,l,h,f,x,M,y),i&&(i.faceIndex=Math.floor(m/3),e.push(i))}}}};function yg(s,t,e,n,i,r,o,a){let c;if(t.side===Ne?c=n.intersectTriangle(o,r,i,!0,a):c=n.intersectTriangle(i,r,o,t.side===pn,a),c===null)return null;ya.copy(a),ya.applyMatrix4(s.matrixWorld);let l=e.ray.origin.distanceTo(ya);return l<e.near||l>e.far?null:{distance:l,point:ya.clone(),object:s}}function va(s,t,e,n,i,r,o,a,c,l){s.getVertexPosition(a,ma),s.getVertexPosition(c,ga),s.getVertexPosition(l,_a);let h=yg(s,t,e,n,ma,ga,_a,Vf);if(h){let f=new R;on.getBarycoord(Vf,ma,ga,_a,f),i&&(h.uv=on.getInterpolatedAttribute(i,a,c,l,f,new At)),r&&(h.uv1=on.getInterpolatedAttribute(r,a,c,l,f,new At)),o&&(h.normal=on.getInterpolatedAttribute(o,a,c,l,f,new R),h.normal.dot(n.direction)>0&&h.normal.multiplyScalar(-1));let u={a,b:c,c:l,normal:new R,materialIndex:0};on.getNormal(ma,ga,_a,u.normal),h.face=u,h.barycoord=f}return h}var Zr=new Zt,Gf=new Zt,Hf=new Zt,vg=new Zt,Wf=new _t,Ma=new R,th=new yn,Xf=new _t,eh=new ti,lo=class extends Ee{constructor(t,e){super(t,e),this.isSkinnedMesh=!0,this.type="SkinnedMesh",this.bindMode=oh,this.bindMatrix=new _t,this.bindMatrixInverse=new _t,this.boundingBox=null,this.boundingSphere=null}computeBoundingBox(){let t=this.geometry;this.boundingBox===null&&(this.boundingBox=new Jt),this.boundingBox.makeEmpty();let e=t.getAttribute("position");for(let n=0;n<e.count;n++)this.getVertexPosition(n,Ma),this.boundingBox.expandByPoint(Ma)}computeBoundingSphere(){let t=this.geometry;this.boundingSphere===null&&(this.boundingSphere=new yn),this.boundingSphere.makeEmpty();let e=t.getAttribute("position");for(let n=0;n<e.count;n++)this.getVertexPosition(n,Ma),this.boundingSphere.expandByPoint(Ma)}copy(t,e){return super.copy(t,e),this.bindMode=t.bindMode,this.bindMatrix.copy(t.bindMatrix),this.bindMatrixInverse.copy(t.bindMatrixInverse),this.skeleton=t.skeleton,this.boundingBox=t.boundingBox!==null?t.boundingBox.clone():null,this.boundingSphere=t.boundingSphere!==null?t.boundingSphere.clone():null,this}raycast(t,e){let n=this.material,i=this.matrixWorld;n!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),th.copy(this.boundingSphere),th.applyMatrix4(i),t.ray.intersectsSphere(th)!==!1&&(Xf.copy(i).invert(),eh.copy(t.ray).applyMatrix4(Xf),!(this.boundingBox!==null&&eh.intersectsBox(this.boundingBox)===!1)&&this._computeIntersections(t,e,eh)))}getVertexPosition(t,e){return super.getVertexPosition(t,e),this.applyBoneTransform(t,e),e}bind(t,e){this.skeleton=t,e===void 0&&(this.updateMatrixWorld(!0),this.skeleton.calculateInverses(),e=this.matrixWorld),this.bindMatrix.copy(e),this.bindMatrixInverse.copy(e).invert()}pose(){this.skeleton.pose()}normalizeSkinWeights(){let t=new Zt,e=this.geometry.attributes.skinWeight;for(let n=0,i=e.count;n<i;n++){t.fromBufferAttribute(e,n);let r=1/t.manhattanLength();r!==1/0?t.multiplyScalar(r):t.set(1,0,0,0),e.setXYZW(n,t.x,t.y,t.z,t.w)}}updateMatrixWorld(t){super.updateMatrixWorld(t),this.bindMode===oh?this.bindMatrixInverse.copy(this.matrixWorld).invert():this.bindMode===Od?this.bindMatrixInverse.copy(this.bindMatrix).invert():Tt("SkinnedMesh: Unrecognized bindMode: "+this.bindMode)}applyBoneTransform(t,e){let n=this.skeleton,i=this.geometry;Gf.fromBufferAttribute(i.attributes.skinIndex,t),Hf.fromBufferAttribute(i.attributes.skinWeight,t),e.isVector4?(Zr.copy(e),e.set(0,0,0,0)):(Zr.set(e.x,e.y,e.z,1),e.set(0,0,0)),Zr.applyMatrix4(this.bindMatrix);for(let r=0;r<4;r++){let o=Hf.getComponent(r);if(o!==0){let a=Gf.getComponent(r);Wf.multiplyMatrices(n.bones[a].matrixWorld,n.boneInverses[a]),e.addScaledVector(vg.copy(Zr).applyMatrix4(Wf),o)}}return e.isVector4&&(e.w=Zr.w),e.applyMatrix4(this.bindMatrixInverse)}},hr=class extends Ae{constructor(){super(),this.isBone=!0,this.type="Bone"}},ur=class extends ke{constructor(t=null,e=1,n=1,i,r,o,a,c,l=xe,h=xe,f,u){super(null,o,a,c,l,h,i,r,f,u),this.isDataTexture=!0,this.image={data:t,width:e,height:n},this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}},qf=new _t,Mg=new _t,ho=class s{constructor(t=[],e=[]){this.uuid=oi(),this.bones=t.slice(0),this.boneInverses=e,this.boneMatrices=null,this.previousBoneMatrices=null,this.boneTexture=null,this.previousBoneTexture=null,this.init()}init(){let t=this.bones,e=this.boneInverses;if(this.boneMatrices=new Float32Array(t.length*16),e.length===0)this.calculateInverses();else if(t.length!==e.length){Tt("Skeleton: Number of inverse bone matrices does not match amount of bones."),this.boneInverses=[];for(let n=0,i=this.bones.length;n<i;n++)this.boneInverses.push(new _t)}}calculateInverses(){this.boneInverses.length=0;for(let t=0,e=this.bones.length;t<e;t++){let n=new _t;this.bones[t]&&n.copy(this.bones[t].matrixWorld).invert(),this.boneInverses.push(n)}}pose(){for(let t=0,e=this.bones.length;t<e;t++){let n=this.bones[t];n&&n.matrixWorld.copy(this.boneInverses[t]).invert()}for(let t=0,e=this.bones.length;t<e;t++){let n=this.bones[t];n&&(n.parent&&n.parent.isBone?(n.matrix.copy(n.parent.matrixWorld).invert(),n.matrix.multiply(n.matrixWorld)):n.matrix.copy(n.matrixWorld),n.matrix.decompose(n.position,n.quaternion,n.scale))}}update(){let t=this.bones,e=this.boneInverses,n=this.boneMatrices,i=this.boneTexture;for(let r=0,o=t.length;r<o;r++){let a=t[r]?t[r].matrixWorld:Mg;qf.multiplyMatrices(a,e[r]),qf.toArray(n,r*16)}i!==null&&(i.needsUpdate=!0)}clone(){return new s(this.bones,this.boneInverses)}computeBoneTexture(){let t=Math.sqrt(this.bones.length*4);t=Math.ceil(t/4)*4,t=Math.max(t,4);let e=new Float32Array(t*t*4);e.set(this.boneMatrices);let n=new ur(e,t,t,Fn,An);return n.needsUpdate=!0,this.boneMatrices=e,this.boneTexture=n,this}getBoneByName(t){for(let e=0,n=this.bones.length;e<n;e++){let i=this.bones[e];if(i.name===t)return i}}dispose(){this.boneTexture!==null&&(this.boneTexture.dispose(),this.boneTexture=null),this.previousBoneTexture!==null&&(this.previousBoneTexture.dispose(),this.previousBoneTexture=null)}fromJSON(t,e){this.uuid=t.uuid;for(let n=0,i=t.bones.length;n<i;n++){let r=t.bones[n],o=e[r];o===void 0&&(Tt("Skeleton: No bone found with UUID:",r),o=new hr),this.bones.push(o),this.boneInverses.push(new _t().fromArray(t.boneInverses[n]))}return this.init(),this}toJSON(){let t={metadata:{version:4.7,type:"Skeleton",generator:"Skeleton.toJSON"},bones:[],boneInverses:[]};t.uuid=this.uuid;let e=this.bones,n=this.boneInverses;for(let i=0,r=e.length;i<r;i++){let o=e[i];t.bones.push(o.uuid);let a=n[i];t.boneInverses.push(a.toArray())}return t}},wi=class extends Te{constructor(t,e,n,i=1){super(t,e,n),this.isInstancedBufferAttribute=!0,this.meshPerAttribute=i}copy(t){return super.copy(t),this.meshPerAttribute=t.meshPerAttribute,this}toJSON(){let t=super.toJSON();return t.meshPerAttribute=this.meshPerAttribute,t.isInstancedBufferAttribute=!0,t}},Ys=new _t,Yf=new _t,Sa=[],Kf=new Jt,Sg=new _t,Jr=new Ee,$r=new yn,ys=class extends Ee{constructor(t,e,n){super(t,e),this.isInstancedMesh=!0,this.instanceMatrix=new wi(new Float32Array(n*16),16),this.instanceColor=null,this.morphTexture=null,this.count=n,this.boundingBox=null,this.boundingSphere=null;for(let i=0;i<n;i++)this.setMatrixAt(i,Sg)}computeBoundingBox(){let t=this.geometry,e=this.count;this.boundingBox===null&&(this.boundingBox=new Jt),t.boundingBox===null&&t.computeBoundingBox(),this.boundingBox.makeEmpty();for(let n=0;n<e;n++)this.getMatrixAt(n,Ys),Kf.copy(t.boundingBox).applyMatrix4(Ys),this.boundingBox.union(Kf)}computeBoundingSphere(){let t=this.geometry,e=this.count;this.boundingSphere===null&&(this.boundingSphere=new yn),t.boundingSphere===null&&t.computeBoundingSphere(),this.boundingSphere.makeEmpty();for(let n=0;n<e;n++)this.getMatrixAt(n,Ys),$r.copy(t.boundingSphere).applyMatrix4(Ys),this.boundingSphere.union($r)}copy(t,e){return super.copy(t,e),this.instanceMatrix.copy(t.instanceMatrix),this.morphTexture=t.morphTexture!==null?t.morphTexture.clone():null,this.instanceColor=t.instanceColor!==null?t.instanceColor.clone():null,this.count=t.count,this.boundingBox=t.boundingBox!==null?t.boundingBox.clone():null,this.boundingSphere=t.boundingSphere!==null?t.boundingSphere.clone():null,this}getColorAt(t,e){return this.instanceColor===null?e.setRGB(1,1,1):e.fromArray(this.instanceColor.array,t*3)}getMatrixAt(t,e){return e.fromArray(this.instanceMatrix.array,t*16)}getMorphAt(t,e){let n=e.morphTargetInfluences,i=this.morphTexture.source.data.data,r=n.length+1,o=t*r+1;for(let a=0;a<n.length;a++)n[a]=i[o+a]}raycast(t,e){let n=this.matrixWorld,i=this.count;if(Jr.geometry=this.geometry,Jr.material=this.material,Jr.material!==void 0&&(this.boundingSphere===null&&this.computeBoundingSphere(),$r.copy(this.boundingSphere),$r.applyMatrix4(n),t.ray.intersectsSphere($r)!==!1))for(let r=0;r<i;r++){this.getMatrixAt(r,Ys),Yf.multiplyMatrices(n,Ys),Jr.matrixWorld=Yf,Jr.raycast(t,Sa);for(let o=0,a=Sa.length;o<a;o++){let c=Sa[o];c.instanceId=r,c.object=this,e.push(c)}Sa.length=0}}setColorAt(t,e){return this.instanceColor===null&&(this.instanceColor=new wi(new Float32Array(this.instanceMatrix.count*3).fill(1),3)),e.toArray(this.instanceColor.array,t*3),this}setMatrixAt(t,e){return e.toArray(this.instanceMatrix.array,t*16),this}setMorphAt(t,e){let n=e.morphTargetInfluences,i=n.length+1;this.morphTexture===null&&(this.morphTexture=new ur(new Float32Array(i*this.count),i,this.count,cc,An));let r=this.morphTexture.source.data.data,o=0;for(let l=0;l<n.length;l++)o+=n[l];let a=this.geometry.morphTargetsRelative?1:1-o,c=i*t;return r[c]=a,r.set(n,c+1),this}updateMorphTargets(){}dispose(){super.dispose(),this.instanceMatrix.dispose(),this.instanceColor!==null&&this.instanceColor.dispose(),this.morphTexture!==null&&(this.morphTexture.dispose(),this.morphTexture=null)}},ds=new yn,bg=new At(.5,.5),ba=new R,Ki=class{constructor(t=new $e,e=new $e,n=new $e,i=new $e,r=new $e,o=new $e){this.planes=[t,e,n,i,r,o]}set(t,e,n,i,r,o){let a=this.planes;return a[0].copy(t),a[1].copy(e),a[2].copy(n),a[3].copy(i),a[4].copy(r),a[5].copy(o),this}copy(t){let e=this.planes;for(let n=0;n<6;n++)e[n].copy(t.planes[n]);return this}setFromProjectionMatrix(t,e=Dn,n=!1){let i=this.planes,r=t.elements,o=r[0],a=r[1],c=r[2],l=r[3],h=r[4],f=r[5],u=r[6],d=r[7],g=r[8],v=r[9],m=r[10],p=r[11],x=r[12],M=r[13],y=r[14],S=r[15];if(i[0].setComponents(l-o,d-h,p-g,S-x).normalize(),i[1].setComponents(l+o,d+h,p+g,S+x).normalize(),i[2].setComponents(l+a,d+f,p+v,S+M).normalize(),i[3].setComponents(l-a,d-f,p-v,S-M).normalize(),n)i[4].setComponents(c,u,m,y).normalize(),i[5].setComponents(l-c,d-u,p-m,S-y).normalize();else if(i[4].setComponents(l-c,d-u,p-m,S-y).normalize(),e===Dn)i[5].setComponents(l+c,d+u,p+m,S+y).normalize();else if(e===nr)i[5].setComponents(c,u,m,y).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+e);return this}intersectsObject(t){if(t.boundingSphere!==void 0)t.boundingSphere===null&&t.computeBoundingSphere(),ds.copy(t.boundingSphere).applyMatrix4(t.matrixWorld);else{let e=t.geometry;e.boundingSphere===null&&e.computeBoundingSphere(),ds.copy(e.boundingSphere).applyMatrix4(t.matrixWorld)}return this.intersectsSphere(ds)}intersectsSprite(t){ds.center.set(0,0,0);let e=bg.distanceTo(t.center);return ds.radius=.7071067811865476+e,ds.applyMatrix4(t.matrixWorld),this.intersectsSphere(ds)}intersectsSphere(t){let e=this.planes,n=t.center,i=-t.radius;for(let r=0;r<6;r++)if(e[r].distanceToPoint(n)<i)return!1;return!0}intersectsBox(t){let e=this.planes;for(let n=0;n<6;n++){let i=e[n];if(ba.x=i.normal.x>0?t.max.x:t.min.x,ba.y=i.normal.y>0?t.max.y:t.min.y,ba.z=i.normal.z>0?t.max.z:t.min.z,i.distanceToPoint(ba)<0)return!1}return!0}containsPoint(t){let e=this.planes;for(let n=0;n<6;n++)if(e[n].distanceToPoint(t)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}},Zf=new _t,Ha=class s{constructor(){this.coordinateSystem=Dn,this._frustums=[],this._count=0}setFromArrayCamera(t){let e=t.cameras,n=this._frustums;for(let i=0;i<e.length;i++){let r=e[i];Zf.multiplyMatrices(r.projectionMatrix,r.matrixWorldInverse),n[i]===void 0&&(n[i]=new Ki),n[i].setFromProjectionMatrix(Zf,r.coordinateSystem,r.reversedDepth)}return this._count=e.length,this}getFrustum(t){return this._frustums[t]}intersectsObject(t){let e=this._frustums;for(let n=0;n<this._count;n++)if(e[n].intersectsObject(t))return!0;return!1}intersectsSprite(t){let e=this._frustums;for(let n=0;n<this._count;n++)if(e[n].intersectsSprite(t))return!0;return!1}intersectsSphere(t){let e=this._frustums;for(let n=0;n<this._count;n++)if(e[n].intersectsSphere(t))return!0;return!1}intersectsBox(t){let e=this._frustums;for(let n=0;n<this._count;n++)if(e[n].intersectsBox(t))return!0;return!1}containsPoint(t){let e=this._frustums;for(let n=0;n<this._count;n++)if(e[n].containsPoint(t))return!0;return!1}copy(t){this.coordinateSystem=t.coordinateSystem;let e=this._frustums,n=t._frustums;for(let i=0;i<t._count;i++)e[i]===void 0&&(e[i]=new Ki),e[i].copy(n[i]);return this._count=t._count,this}clone(){return new s().copy(this)}};var Wn=class extends vn{constructor(t){super(),this.isLineBasicMaterial=!0,this.type="LineBasicMaterial",this.color=new Pt(16777215),this.map=null,this.linewidth=1,this.linecap="round",this.linejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.linewidth=t.linewidth,this.linecap=t.linecap,this.linejoin=t.linejoin,this.fog=t.fog,this}},Wa=new R,Xa=new R,Jf=new _t,jr=new ti,Ta=new yn,nh=new R,$f=new R,Un=class extends Ae{constructor(t=new ye,e=new Wn){super(),this.isLine=!0,this.type="Line",this.geometry=t,this.material=e,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0?this.morphTargetInfluences=t.morphTargetInfluences.slice():this.morphTargetInfluences=void 0,t.morphTargetDictionary!==void 0?this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary):this.morphTargetDictionary=void 0,this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}computeLineDistances(){let t=this.geometry;if(t.index===null){let e=t.attributes.position,n=[0];for(let i=1,r=e.count;i<r;i++)Wa.fromBufferAttribute(e,i-1),Xa.fromBufferAttribute(e,i),n[i]=n[i-1],n[i]+=Wa.distanceTo(Xa);t.setAttribute("lineDistance",new ae(n,1))}else Tt("Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}intersectsFrustum(t){return t.intersectsObject(this)}raycast(t,e){let n=this.geometry,i=this.matrixWorld,r=t.params.Line.threshold,o=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),Ta.copy(n.boundingSphere),Ta.applyMatrix4(i),Ta.radius+=r,t.ray.intersectsSphere(Ta)===!1)return;Jf.copy(i).invert(),jr.copy(t.ray).applyMatrix4(Jf);let a=r/((this.scale.x+this.scale.y+this.scale.z)/3),c=a*a,l=this.isLineSegments?2:1,h=n.index,u=n.attributes.position;if(h!==null){let d=Math.max(0,o.start),g=Math.min(h.count,o.start+o.count);for(let v=d,m=g-1;v<m;v+=l){let p=h.getX(v),x=h.getX(v+1),M=wa(this,t,jr,c,p,x,v);M&&e.push(M)}if(this.isLineLoop){let v=h.getX(g-1),m=h.getX(d),p=wa(this,t,jr,c,v,m,g-1);p&&e.push(p)}}else{let d=Math.max(0,o.start),g=Math.min(u.count,o.start+o.count);for(let v=d,m=g-1;v<m;v+=l){let p=wa(this,t,jr,c,v,v+1,v);p&&e.push(p)}if(this.isLineLoop){let v=wa(this,t,jr,c,g-1,d,g-1);v&&e.push(v)}}}updateMorphTargets(){let e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){let i=e[n[0]];if(i!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,o=i.length;r<o;r++){let a=i[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=r}}}}};function wa(s,t,e,n,i,r,o){let a=s.geometry.attributes.position;if(Wa.fromBufferAttribute(a,i),Xa.fromBufferAttribute(a,r),e.distanceSqToSegment(Wa,Xa,nh,$f)>n)return;nh.applyMatrix4(s.matrixWorld);let l=t.ray.origin.distanceTo(nh);if(!(l<t.near||l>t.far))return{distance:l,point:$f.clone().applyMatrix4(s.matrixWorld),index:o,face:null,faceIndex:null,barycoord:null,object:s}}var jf=new R,Qf=new R,uo=class extends Un{constructor(t,e){super(t,e),this.isLineSegments=!0,this.type="LineSegments"}computeLineDistances(){let t=this.geometry;if(t.index===null){let e=t.attributes.position,n=[];for(let i=0,r=e.count;i<r;i+=2)jf.fromBufferAttribute(e,i),Qf.fromBufferAttribute(e,i+1),n[i]=i===0?0:n[i-1],n[i+1]=n[i]+jf.distanceTo(Qf);t.setAttribute("lineDistance",new ae(n,1))}else Tt("LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");return this}},fo=class extends Un{constructor(t,e){super(t,e),this.isLineLoop=!0,this.type="LineLoop"}},fr=class extends vn{constructor(t){super(),this.isPointsMaterial=!0,this.type="PointsMaterial",this.color=new Pt(16777215),this.map=null,this.alphaMap=null,this.size=1,this.sizeAttenuation=!0,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.alphaMap=t.alphaMap,this.size=t.size,this.sizeAttenuation=t.sizeAttenuation,this.fog=t.fog,this}},td=new _t,uh=new ti,Aa=new yn,Ea=new R,po=class extends Ae{constructor(t=new ye,e=new fr){super(),this.isPoints=!0,this.type="Points",this.geometry=t,this.material=e,this.morphTargetDictionary=void 0,this.morphTargetInfluences=void 0,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0?this.morphTargetInfluences=t.morphTargetInfluences.slice():this.morphTargetInfluences=void 0,t.morphTargetDictionary!==void 0?this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary):this.morphTargetDictionary=void 0,this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}intersectsFrustum(t){return t.intersectsObject(this)}raycast(t,e){let n=this.geometry,i=this.matrixWorld,r=t.params.Points.threshold,o=n.drawRange;if(n.boundingSphere===null&&n.computeBoundingSphere(),Aa.copy(n.boundingSphere),Aa.applyMatrix4(i),Aa.radius+=r,t.ray.intersectsSphere(Aa)===!1)return;td.copy(i).invert(),uh.copy(t.ray).applyMatrix4(td);let a=r/((this.scale.x+this.scale.y+this.scale.z)/3),c=a*a,l=n.index,f=n.attributes.position;if(l!==null){let u=Math.max(0,o.start),d=Math.min(l.count,o.start+o.count);for(let g=u,v=d;g<v;g++){let m=l.getX(g);Ea.fromBufferAttribute(f,m),ed(Ea,m,c,i,t,e,this)}}else{let u=Math.max(0,o.start),d=Math.min(f.count,o.start+o.count);for(let g=u,v=d;g<v;g++)Ea.fromBufferAttribute(f,g),ed(Ea,g,c,i,t,e,this)}}updateMorphTargets(){let e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){let i=e[n[0]];if(i!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let r=0,o=i.length;r<o;r++){let a=i[r].name||String(r);this.morphTargetInfluences.push(0),this.morphTargetDictionary[a]=r}}}}};function ed(s,t,e,n,i,r,o){let a=uh.distanceSqToPoint(s);if(a<e){let c=new R;uh.closestPointToPoint(s,c),c.applyMatrix4(n);let l=i.ray.origin.distanceTo(c);if(l<i.near||l>i.far)return;r.push({distance:l,distanceToRay:Math.sqrt(a),point:c,index:t,face:null,faceIndex:null,barycoord:null,object:o})}}var mo=class extends ke{constructor(t=[],e=As,n,i,r,o,a,c,l,h){super(t,e,n,i,r,o,a,c,l,h),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(t){this.image=t}},Ai=class extends ke{constructor(t,e,n,i,r,o,a,c,l){super(t,e,n,i,r,o,a,c,l),this.isCanvasTexture=!0,this.needsUpdate=!0}};var Ei=class extends ke{constructor(t,e,n=Yn,i,r,o,a=xe,c=xe,l,h=bi,f=1){if(h!==bi&&h!==Di)throw new Error("THREE.DepthTexture: format must be either THREE.DepthFormat or THREE.DepthStencilFormat");let u={width:t,height:e,depth:f};super(u,i,r,o,a,c,h,n,l),this.isDepthTexture=!0,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(t){return super.copy(t),this.source=new rr(Object.assign({},t.image)),this.compareFunction=t.compareFunction,this}toJSON(t){let e=super.toJSON(t);return e.compareFunction=this.compareFunction,e}},go=class extends Ei{constructor(t,e=Yn,n=As,i,r,o=xe,a=xe,c,l=bi){let h={width:t,height:t,depth:1},f=[h,h,h,h,h,h];super(t,t,e,n,i,r,o,a,c,l),this.image=f,this.isCubeDepthTexture=!0,this.isCubeTexture=!0}get images(){return this.image}set images(t){this.image=t}},_o=class extends ke{constructor(t=null){super(),this.sourceTexture=t,this.isExternalTexture=!0}copy(t){return super.copy(t),this.sourceTexture=t.sourceTexture,this}},dr=class s extends ye{constructor(t=1,e=1,n=1,i=1,r=1,o=1){super(),this.type="BoxGeometry",this.parameters={width:t,height:e,depth:n,widthSegments:i,heightSegments:r,depthSegments:o};let a=this;i=Math.floor(i),r=Math.floor(r),o=Math.floor(o);let c=[],l=[],h=[],f=[],u=0,d=0;g("z","y","x",-1,-1,n,e,t,o,r,0),g("z","y","x",1,-1,n,e,-t,o,r,1),g("x","z","y",1,1,t,n,e,i,o,2),g("x","z","y",1,-1,t,n,-e,i,o,3),g("x","y","z",1,-1,t,e,n,i,r,4),g("x","y","z",-1,-1,t,e,-n,i,r,5),this.setIndex(c),this.setAttribute("position",new ae(l,3)),this.setAttribute("normal",new ae(h,3)),this.setAttribute("uv",new ae(f,2));function g(v,m,p,x,M,y,S,T,_,b,I){let E=y/_,L=S/b,C=y/2,U=S/2,N=T/2,B=_+1,G=b+1,H=0,tt=0,X=new R;for(let j=0;j<G;j++){let Q=j*L-U;for(let yt=0;yt<B;yt++){let Ut=yt*E-C;X[v]=Ut*x,X[m]=Q*M,X[p]=N,l.push(X.x,X.y,X.z),X[v]=0,X[m]=0,X[p]=T>0?1:-1,h.push(X.x,X.y,X.z),f.push(yt/_),f.push(1-j/b),H+=1}}for(let j=0;j<b;j++)for(let Q=0;Q<_;Q++){let yt=u+Q+B*j,Ut=u+Q+B*(j+1),Z=u+(Q+1)+B*(j+1),lt=u+(Q+1)+B*j;c.push(yt,Ut,lt),c.push(Ut,Z,lt),tt+=6}a.addGroup(d,tt,I),d+=tt,u+=H}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.width,t.height,t.depth,t.widthSegments,t.heightSegments,t.depthSegments)}};var xo=class s extends ye{constructor(t=1,e=1,n=1,i=32,r=1,o=!1,a=0,c=Math.PI*2){super(),this.type="CylinderGeometry",this.parameters={radiusTop:t,radiusBottom:e,height:n,radialSegments:i,heightSegments:r,openEnded:o,thetaStart:a,thetaLength:c};let l=this;i=Math.floor(i),r=Math.floor(r);let h=[],f=[],u=[],d=[],g=0,v=[],m=n/2,p=0;x(),o===!1&&(t>0&&M(!0),e>0&&M(!1)),this.setIndex(h),this.setAttribute("position",new ae(f,3)),this.setAttribute("normal",new ae(u,3)),this.setAttribute("uv",new ae(d,2));function x(){let y=new R,S=new R,T=0,_=(e-t)/n;for(let b=0;b<=r;b++){let I=[],E=b/r,L=E*(e-t)+t;for(let C=0;C<=i;C++){let U=C/i,N=U*c+a,B=Math.sin(N),G=Math.cos(N);S.x=L*B,S.y=-E*n+m,S.z=L*G,f.push(S.x,S.y,S.z),y.set(B,_,G).normalize(),u.push(y.x,y.y,y.z),d.push(U,1-E),I.push(g++)}v.push(I)}for(let b=0;b<i;b++)for(let I=0;I<r;I++){let E=v[I][b],L=v[I+1][b],C=v[I+1][b+1],U=v[I][b+1];(t>0||I!==0)&&(h.push(E,L,U),T+=3),(e>0||I!==r-1)&&(h.push(L,C,U),T+=3)}l.addGroup(p,T,0),p+=T}function M(y){let S=g,T=new At,_=new R,b=0,I=y===!0?t:e,E=y===!0?1:-1;for(let C=1;C<=i;C++)f.push(0,m*E,0),u.push(0,E,0),d.push(.5,.5),g++;let L=g;for(let C=0;C<=i;C++){let N=C/i*c+a,B=Math.cos(N),G=Math.sin(N);_.x=I*G,_.y=m*E,_.z=I*B,f.push(_.x,_.y,_.z),u.push(0,E,0),T.x=B*.5+.5,T.y=G*.5*E+.5,d.push(T.x,T.y),g++}for(let C=0;C<i;C++){let U=S+C,N=L+C;y===!0?h.push(N,N+1,U):h.push(N+1,N,U),b+=3}l.addGroup(p,b,y===!0?1:2),p+=b}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.radiusTop,t.radiusBottom,t.height,t.radialSegments,t.heightSegments,t.openEnded,t.thetaStart,t.thetaLength)}};var Ri=class s extends ye{constructor(t=1,e=1,n=1,i=1){super(),this.type="PlaneGeometry",this.parameters={width:t,height:e,widthSegments:n,heightSegments:i};let r=t/2,o=e/2,a=Math.floor(n),c=Math.floor(i),l=a+1,h=c+1,f=t/a,u=e/c,d=[],g=[],v=[],m=[];for(let p=0;p<h;p++){let x=p*u-o;for(let M=0;M<l;M++){let y=M*f-r;g.push(y,-x,0),v.push(0,0,1),m.push(M/a),m.push(1-p/c)}}for(let p=0;p<c;p++)for(let x=0;x<a;x++){let M=x+l*p,y=x+l*(p+1),S=x+1+l*(p+1),T=x+1+l*p;d.push(M,y,T),d.push(y,S,T)}this.setIndex(d),this.setAttribute("position",new ae(g,3)),this.setAttribute("normal",new ae(v,3)),this.setAttribute("uv",new ae(m,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.width,t.height,t.widthSegments,t.heightSegments)}},yo=class s extends ye{constructor(t=.5,e=1,n=32,i=1,r=0,o=Math.PI*2){super(),this.type="RingGeometry",this.parameters={innerRadius:t,outerRadius:e,thetaSegments:n,phiSegments:i,thetaStart:r,thetaLength:o},n=Math.max(3,n),i=Math.max(1,i);let a=[],c=[],l=[],h=[],f=t,u=(e-t)/i,d=new R,g=new At;for(let v=0;v<=i;v++){for(let m=0;m<=n;m++){let p=r+m/n*o;d.x=f*Math.cos(p),d.y=f*Math.sin(p),c.push(d.x,d.y,d.z),l.push(0,0,1),g.x=(d.x/e+1)/2,g.y=(d.y/e+1)/2,h.push(g.x,g.y)}f+=u}for(let v=0;v<i;v++){let m=v*(n+1);for(let p=0;p<n;p++){let x=p+m,M=x,y=x+n+1,S=x+n+2,T=x+1;a.push(M,y,T),a.push(y,S,T)}}this.setIndex(a),this.setAttribute("position",new ae(c,3)),this.setAttribute("normal",new ae(l,3)),this.setAttribute("uv",new ae(h,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.innerRadius,t.outerRadius,t.thetaSegments,t.phiSegments,t.thetaStart,t.thetaLength)}};var pr=class s extends ye{constructor(t=1,e=32,n=16,i=0,r=Math.PI*2,o=0,a=Math.PI){super(),this.type="SphereGeometry",this.parameters={radius:t,widthSegments:e,heightSegments:n,phiStart:i,phiLength:r,thetaStart:o,thetaLength:a},e=Math.max(3,Math.floor(e)),n=Math.max(2,Math.floor(n));let c=Math.min(o+a,Math.PI),l=0,h=[],f=new R,u=new R,d=[],g=[],v=[],m=[];for(let p=0;p<=n;p++){let x=[],M=p/n,y=o+M*a,S=t*Math.cos(y),T=Math.sqrt(t*t-S*S),_=0;p===0&&o===0?_=.5/e:p===n&&c===Math.PI&&(_=-.5/e);for(let b=0;b<=e;b++){let I=b/e,E=i+I*r;f.x=-T*Math.cos(E),f.y=S,f.z=T*Math.sin(E),g.push(f.x,f.y,f.z),u.copy(f).normalize(),v.push(u.x,u.y,u.z),m.push(I+_,1-M),x.push(l++)}h.push(x)}for(let p=0;p<n;p++)for(let x=0;x<e;x++){let M=h[p][x+1],y=h[p][x],S=h[p+1][x],T=h[p+1][x+1];(p!==0||o>0)&&d.push(M,y,T),(p!==n-1||c<Math.PI)&&d.push(y,S,T)}this.setIndex(d),this.setAttribute("position",new ae(g,3)),this.setAttribute("normal",new ae(v,3)),this.setAttribute("uv",new ae(m,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new s(t.radius,t.widthSegments,t.heightSegments,t.phiStart,t.phiLength,t.thetaStart,t.thetaLength)}};function Cs(s){let t={};for(let e in s){t[e]={};for(let n in s[e]){let i=s[e][n];if(nd(i))i.isRenderTargetTexture?(Tt("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),t[e][n]=null):t[e][n]=i.clone();else if(Array.isArray(i))if(nd(i[0])){let r=[];for(let o=0,a=i.length;o<a;o++)r[o]=i[o].clone();t[e][n]=r}else t[e][n]=i.slice();else t[e][n]=i}}return t}function ln(s){let t={};for(let e=0;e<s.length;e++){let n=Cs(s[e]);for(let i in n)t[i]=n[i]}return t}function nd(s){return s&&(s.isColor||s.isMatrix3||s.isMatrix4||s.isVector2||s.isVector3||s.isVector4||s.isTexture||s.isQuaternion)}function Tg(s){let t=[];for(let e=0;e<s.length;e++)t.push(s[e].clone());return t}function Wh(s){let t=s.getRenderTarget();return t===null?s.outputColorSpace:t.isXRRenderTarget===!0?t.texture.colorSpace:Ht.workingColorSpace}var jd={clone:Cs,merge:ln},wg=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,Ag=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`,ei=class extends vn{constructor(t){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=wg,this.fragmentShader=Ag,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={clipCullDistance:!1,multiDraw:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,t!==void 0&&this.setValues(t)}copy(t){return super.copy(t),this.fragmentShader=t.fragmentShader,this.vertexShader=t.vertexShader,this.uniforms=Cs(t.uniforms),this.uniformsGroups=Tg(t.uniformsGroups),this.defines=Object.assign({},t.defines),this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.fog=t.fog,this.lights=t.lights,this.clipping=t.clipping,this.extensions=Object.assign({},t.extensions),this.glslVersion=t.glslVersion,this.defaultAttributeValues=Object.assign({},t.defaultAttributeValues),this.index0AttributeName=t.index0AttributeName,this.uniformsNeedUpdate=t.uniformsNeedUpdate,this}toJSON(t){let e=super.toJSON(t);e.glslVersion=this.glslVersion,e.uniforms={};for(let i in this.uniforms){let o=this.uniforms[i].value;o&&o.isTexture?e.uniforms[i]={type:"t",value:o.toJSON(t).uuid}:o&&o.isColor?e.uniforms[i]={type:"c",value:o.getHex()}:o&&o.isVector2?e.uniforms[i]={type:"v2",value:o.toArray()}:o&&o.isVector3?e.uniforms[i]={type:"v3",value:o.toArray()}:o&&o.isVector4?e.uniforms[i]={type:"v4",value:o.toArray()}:o&&o.isMatrix3?e.uniforms[i]={type:"m3",value:o.toArray()}:o&&o.isMatrix4?e.uniforms[i]={type:"m4",value:o.toArray()}:e.uniforms[i]={value:o}}Object.keys(this.defines).length>0&&(e.defines=this.defines),e.vertexShader=this.vertexShader,e.fragmentShader=this.fragmentShader,e.lights=this.lights,e.clipping=this.clipping;let n={};for(let i in this.extensions)this.extensions[i]===!0&&(n[i]=!0);return Object.keys(n).length>0&&(e.extensions=n),e}fromJSON(t,e){if(super.fromJSON(t,e),t.uniforms!==void 0)for(let n in t.uniforms){let i=t.uniforms[n];switch(this.uniforms[n]={},i.type){case"t":this.uniforms[n].value=e[i.value]||null;break;case"c":this.uniforms[n].value=new Pt().setHex(i.value);break;case"v2":this.uniforms[n].value=new At().fromArray(i.value);break;case"v3":this.uniforms[n].value=new R().fromArray(i.value);break;case"v4":this.uniforms[n].value=new Zt().fromArray(i.value);break;case"m3":this.uniforms[n].value=new Ft().fromArray(i.value);break;case"m4":this.uniforms[n].value=new _t().fromArray(i.value);break;default:this.uniforms[n].value=i.value}}if(t.defines!==void 0&&(this.defines=t.defines),t.vertexShader!==void 0&&(this.vertexShader=t.vertexShader),t.fragmentShader!==void 0&&(this.fragmentShader=t.fragmentShader),t.glslVersion!==void 0&&(this.glslVersion=t.glslVersion),t.extensions!==void 0)for(let n in t.extensions)this.extensions[n]=t.extensions[n];return t.lights!==void 0&&(this.lights=t.lights),t.clipping!==void 0&&(this.clipping=t.clipping),this}},qa=class extends ei{constructor(t){super(t),this.isRawShaderMaterial=!0,this.type="RawShaderMaterial"}},Xn=class extends vn{constructor(t){super(),this.isMeshStandardMaterial=!0,this.type="MeshStandardMaterial",this.defines={STANDARD:""},this.color=new Pt(16777215),this.roughness=1,this.metalness=0,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new Pt(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Gc,this.normalScale=new At(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.roughnessMap=null,this.metalnessMap=null,this.alphaMap=null,this.envMap=null,this.envMapRotation=new Ti,this.envMapIntensity=1,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.flatShading=!1,this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.defines={STANDARD:""},this.color.copy(t.color),this.roughness=t.roughness,this.metalness=t.metalness,this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.emissive.copy(t.emissive),this.emissiveMap=t.emissiveMap,this.emissiveIntensity=t.emissiveIntensity,this.bumpMap=t.bumpMap,this.bumpScale=t.bumpScale,this.normalMap=t.normalMap,this.normalMapType=t.normalMapType,this.normalScale.copy(t.normalScale),this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.roughnessMap=t.roughnessMap,this.metalnessMap=t.metalnessMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.envMapRotation.copy(t.envMapRotation),this.envMapIntensity=t.envMapIntensity,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.flatShading=t.flatShading,this.fog=t.fog,this}},dn=class extends Xn{constructor(t){super(),this.isMeshPhysicalMaterial=!0,this.defines={STANDARD:"",PHYSICAL:""},this.type="MeshPhysicalMaterial",this.anisotropyRotation=0,this.anisotropyMap=null,this.clearcoatMap=null,this.clearcoatRoughness=0,this.clearcoatRoughnessMap=null,this.clearcoatNormalScale=new At(1,1),this.clearcoatNormalMap=null,this.diffuseRoughnessMap=null,this.ior=1.5,Object.defineProperty(this,"reflectivity",{get:function(){return kt(2.5*(this.ior-1)/(this.ior+1),0,1)},set:function(e){this.ior=(1+.4*e)/(1-.4*e)}}),this.iridescenceMap=null,this.iridescenceIOR=1.3,this.iridescenceThicknessMinimum=100,this.iridescenceThicknessMaximum=400,this.iridescenceThicknessMap=null,this.sheenColor=new Pt(0),this.sheenColorMap=null,this.sheenRoughness=1,this.sheenRoughnessMap=null,this.transmissionMap=null,this.thickness=0,this.thicknessMap=null,this.attenuationDistance=1/0,this.attenuationColor=new Pt(1,1,1),this.specularIntensity=1,this.specularIntensityMap=null,this.specularColor=new Pt(1,1,1),this.specularColorMap=null,this._anisotropy=0,this._clearcoat=0,this._diffuseRoughness=0,this._dispersion=0,this._iridescence=0,this._retroreflectivity=0,this._sheen=0,this._transmission=0,this.setValues(t)}get anisotropy(){return this._anisotropy}set anisotropy(t){this._anisotropy>0!=t>0&&this.version++,this._anisotropy=t}get clearcoat(){return this._clearcoat}set clearcoat(t){this._clearcoat>0!=t>0&&this.version++,this._clearcoat=t}get diffuseRoughness(){return this._diffuseRoughness}set diffuseRoughness(t){this._diffuseRoughness>0!=t>0&&this.version++,this._diffuseRoughness=t}get iridescence(){return this._iridescence}set iridescence(t){this._iridescence>0!=t>0&&this.version++,this._iridescence=t}get dispersion(){return this._dispersion}set dispersion(t){this._dispersion>0!=t>0&&this.version++,this._dispersion=t}get retroreflectivity(){return this._retroreflectivity}set retroreflectivity(t){this._retroreflectivity>0!=t>0&&this.version++,this._retroreflectivity=t}get sheen(){return this._sheen}set sheen(t){this._sheen>0!=t>0&&this.version++,this._sheen=t}get transmission(){return this._transmission}set transmission(t){this._transmission>0!=t>0&&this.version++,this._transmission=t}get iridescenceThicknessRange(){return ps('MeshPhysicalMaterial: The "iridescenceThicknessRange" property has been replaced by "iridescenceThicknessMinimum" and "iridescenceThicknessMaximum".'),[this.iridescenceThicknessMinimum,this.iridescenceThicknessMaximum]}set iridescenceThicknessRange(t){ps('MeshPhysicalMaterial: The "iridescenceThicknessRange" property has been replaced by "iridescenceThicknessMinimum" and "iridescenceThicknessMaximum".'),this.iridescenceThicknessMinimum=t[0],this.iridescenceThicknessMaximum=t[1]}copy(t){return super.copy(t),this.defines={STANDARD:"",PHYSICAL:""},this.anisotropy=t.anisotropy,this.anisotropyRotation=t.anisotropyRotation,this.anisotropyMap=t.anisotropyMap,this.clearcoat=t.clearcoat,this.clearcoatMap=t.clearcoatMap,this.clearcoatRoughness=t.clearcoatRoughness,this.clearcoatRoughnessMap=t.clearcoatRoughnessMap,this.clearcoatNormalMap=t.clearcoatNormalMap,this.clearcoatNormalScale.copy(t.clearcoatNormalScale),this.diffuseRoughness=t.diffuseRoughness,this.diffuseRoughnessMap=t.diffuseRoughnessMap,this.dispersion=t.dispersion,this.ior=t.ior,this.iridescence=t.iridescence,this.iridescenceMap=t.iridescenceMap,this.iridescenceIOR=t.iridescenceIOR,this.iridescenceThicknessMinimum=t.iridescenceThicknessMinimum,this.iridescenceThicknessMaximum=t.iridescenceThicknessMaximum,this.iridescenceThicknessMap=t.iridescenceThicknessMap,this.retroreflectivity=t.retroreflectivity,this.sheen=t.sheen,this.sheenColor.copy(t.sheenColor),this.sheenColorMap=t.sheenColorMap,this.sheenRoughness=t.sheenRoughness,this.sheenRoughnessMap=t.sheenRoughnessMap,this.transmission=t.transmission,this.transmissionMap=t.transmissionMap,this.thickness=t.thickness,this.thicknessMap=t.thicknessMap,this.attenuationDistance=t.attenuationDistance,this.attenuationColor.copy(t.attenuationColor),this.specularIntensity=t.specularIntensity,this.specularIntensityMap=t.specularIntensityMap,this.specularColor.copy(t.specularColor),this.specularColorMap=t.specularColorMap,this}};var Ya=class extends vn{constructor(t){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=zd,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(t)}copy(t){return super.copy(t),this.depthPacking=t.depthPacking,this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this}},Ka=class extends vn{constructor(t){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(t)}copy(t){return super.copy(t),this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this}};function Yi(s,t){return!s||s.constructor===t?s:typeof t.BYTES_PER_ELEMENT=="number"?new t(s):Array.prototype.slice.call(s)}function Qr(s){return s!==void 0&&s.inTangents!==void 0&&s.outTangents!==void 0}function Eg(s){function t(i,r){return s[i]-s[r]}let e=s.length,n=new Array(e);for(let i=0;i!==e;++i)n[i]=i;return n.sort(t),n}function id(s,t,e){let n=s.length,i=new s.constructor(n);for(let r=0,o=0;o!==n;++r){let a=e[r]*t;for(let c=0;c!==t;++c)i[o++]=s[a+c]}return i}function Rg(s,t,e,n){let i=1,r=s[0];for(;r!==void 0&&r[n]===void 0;)r=s[i++];if(r===void 0)return;let o=r[n];if(o!==void 0)if(Array.isArray(o))do o=r[n],o!==void 0&&(t.push(r.time),e.push(...o)),r=s[i++];while(r!==void 0);else if(o.toArray!==void 0)do o=r[n],o!==void 0&&(t.push(r.time),o.toArray(e,e.length)),r=s[i++];while(r!==void 0);else do o=r[n],o!==void 0&&(t.push(r.time),e.push(o)),r=s[i++];while(r!==void 0)}var ni=class{constructor(t,e,n,i){this.parameterPositions=t,this._cachedIndex=0,this.resultBuffer=i!==void 0?i:new e.constructor(n),this.sampleValues=e,this.valueSize=n,this.settings=null,this.DefaultSettings_={}}evaluate(t){let e=this.parameterPositions,n=this._cachedIndex,i=e[n],r=e[n-1];n:{t:{let o;e:{i:if(!(t<i)){for(let a=n+2;;){if(i===void 0){if(t<r)break i;return n=e.length,this._cachedIndex=n,this.copySampleValue_(n-1)}if(n===a)break;if(r=i,i=e[++n],t<i)break t}o=e.length;break e}if(!(t>=r)){let a=e[1];t<a&&(n=2,r=a);for(let c=n-2;;){if(r===void 0)return this._cachedIndex=0,this.copySampleValue_(0);if(n===c)break;if(i=r,r=e[--n-1],t>=r)break t}o=n,n=0;break e}break n}for(;n<o;){let a=n+o>>>1;t<e[a]?o=a:n=a+1}if(i=e[n],r=e[n-1],r===void 0)return this._cachedIndex=0,this.copySampleValue_(0);if(i===void 0)return n=e.length,this._cachedIndex=n,this.copySampleValue_(n-1)}this._cachedIndex=n,this.intervalChanged_(n,r,i)}return this.interpolate_(n,r,t,i)}getSettings_(){return this.settings||this.DefaultSettings_}copySampleValue_(t){let e=this.resultBuffer,n=this.sampleValues,i=this.valueSize,r=t*i;for(let o=0;o!==i;++o)e[o]=n[r+o];return e}interpolate_(){throw new Error("THREE.Interpolant: Call to abstract method.")}intervalChanged_(){}},Za=class extends ni{constructor(t,e,n,i){super(t,e,n,i),this._weightPrev=-0,this._offsetPrev=-0,this._weightNext=-0,this._offsetNext=-0,this.DefaultSettings_={endingStart:ch,endingEnd:ch}}intervalChanged_(t,e,n){let i=this.parameterPositions,r=t-2,o=t+1,a=i[r],c=i[o];if(a===void 0)switch(this.getSettings_().endingStart){case lh:r=t,a=2*e-n;break;case hh:r=i.length-2,a=e+i[r]-i[r+1];break;default:r=t,a=n}if(c===void 0)switch(this.getSettings_().endingEnd){case lh:o=t,c=2*n-e;break;case hh:o=1,c=n+i[1]-i[0];break;default:o=t-1,c=e}let l=(n-e)*.5,h=this.valueSize;this._weightPrev=l/(e-a),this._weightNext=l/(c-n),this._offsetPrev=r*h,this._offsetNext=o*h}interpolate_(t,e,n,i){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,c=t*a,l=c-a,h=this._offsetPrev,f=this._offsetNext,u=this._weightPrev,d=this._weightNext,g=(n-e)/(i-e),v=g*g,m=v*g,p=-u*m+2*u*v-u*g,x=(1+u)*m+(-1.5-2*u)*v+(-.5+u)*g+1,M=(-1-d)*m+(1.5+d)*v+.5*g,y=d*m-d*v;for(let S=0;S!==a;++S)r[S]=p*o[h+S]+x*o[l+S]+M*o[c+S]+y*o[f+S];return r}},Ja=class extends ni{constructor(t,e,n,i){super(t,e,n,i)}interpolate_(t,e,n,i){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,c=t*a,l=c-a,h=(n-e)/(i-e),f=1-h;for(let u=0;u!==a;++u)r[u]=o[l+u]*f+o[c+u]*h;return r}},$a=class extends ni{constructor(t,e,n,i){super(t,e,n,i)}interpolate_(t){return this.copySampleValue_(t-1)}},ja=class extends ni{interpolate_(t,e,n,i){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,c=t*a,l=c-a,h=this.inTangents,f=this.outTangents;if(!h||!f){let g=(n-e)/(i-e),v=1-g;for(let m=0;m!==a;++m)r[m]=o[l+m]*v+o[c+m]*g;return r}let u=a*2,d=t-1;for(let g=0;g!==a;++g){let v=o[l+g],m=o[c+g],p=d*u+g*2,x=f[p],M=f[p+1],y=t*u+g*2,S=h[y],T=h[y+1],_=Pg(n,e,x,S,i);r[g]=Qd(_,v,M,T,m)}return r}};function Qd(s,t,e,n,i){let r=1-s;return r*r*r*t+3*r*r*s*e+3*r*s*s*n+s*s*s*i}function Cg(s,t,e,n,i){let r=1-s;return 3*r*r*(e-t)+6*r*s*(n-e)+3*s*s*(i-n)}function Pg(s,t,e,n,i){let r=(s-t)/(i-t);for(let o=0;o<8;o++){let a=Qd(r,t,e,n,i)-s;if(Math.abs(a)<1e-10)break;let c=Cg(r,t,e,n,i);if(Math.abs(c)<1e-10)break;r=Math.max(0,Math.min(1,r-a/c))}return r}var Mn=class{constructor(t,e,n,i){if(t===void 0)throw new Error("THREE.KeyframeTrack: track name is undefined");if(e===void 0||e.length===0)throw new Error("THREE.KeyframeTrack: no keyframes in track named "+t);this.name=t,this.times=Yi(e,this.TimeBufferType),this.values=Yi(n,this.ValueBufferType),this.setInterpolation(i||this.DefaultInterpolation)}static toJSON(t){let e=t.constructor,n;if(e.toJSON!==this.toJSON)n=e.toJSON(t);else{n={name:t.name,times:Yi(t.times,Array),values:Yi(t.values,Array)};let i=t.getInterpolation();i!==t.DefaultInterpolation&&(n.interpolation=i),Qr(t.settings)&&(n.settings={inTangents:Yi(t.settings.inTangents,Array),outTangents:Yi(t.settings.outTangents,Array)})}return n.type=t.ValueTypeName,n}InterpolantFactoryMethodDiscrete(t){return new $a(this.times,this.values,this.getValueSize(),t)}InterpolantFactoryMethodLinear(t){return new Ja(this.times,this.values,this.getValueSize(),t)}InterpolantFactoryMethodSmooth(t){return new Za(this.times,this.values,this.getValueSize(),t)}InterpolantFactoryMethodBezier(t){let e=new ja(this.times,this.values,this.getValueSize(),t);return this.settings&&(e.inTangents=this.settings.inTangents,e.outTangents=this.settings.outTangents),e}setInterpolation(t){let e;switch(t){case ms:e=this.InterpolantFactoryMethodDiscrete;break;case gs:e=this.InterpolantFactoryMethodLinear;break;case Ia:e=this.InterpolantFactoryMethodSmooth;break;case ah:e=this.InterpolantFactoryMethodBezier;break}if(e===void 0){let n="unsupported interpolation for "+this.ValueTypeName+" keyframe track named "+this.name;if(this.createInterpolant===void 0)if(t!==this.DefaultInterpolation)this.setInterpolation(this.DefaultInterpolation);else throw new Error(n);return Tt("KeyframeTrack:",n),this}return this.createInterpolant=e,this}getInterpolation(){switch(this.createInterpolant){case this.InterpolantFactoryMethodDiscrete:return ms;case this.InterpolantFactoryMethodLinear:return gs;case this.InterpolantFactoryMethodSmooth:return Ia;case this.InterpolantFactoryMethodBezier:return ah}}getValueSize(){return this.values.length/this.times.length}shift(t){if(t!==0){let e=this.times;for(let n=0,i=e.length;n!==i;++n)e[n]+=t;Qr(this.settings)&&(sd(this.settings.inTangents,t),sd(this.settings.outTangents,t))}return this}scale(t){if(t!==1){let e=this.times;for(let n=0,i=e.length;n!==i;++n)e[n]*=t;Qr(this.settings)&&(rd(this.settings.inTangents,t),rd(this.settings.outTangents,t))}return this}trim(t,e){let n=this.times,i=n.length,r=0,o=i-1;for(;r!==i&&n[r]<t;)++r;for(;o!==-1&&n[o]>e;)--o;if(++o,r!==0||o!==i){r>=o&&(o=Math.max(o,1),r=o-1);let a=this.getValueSize();this.times=n.slice(r,o),this.values=this.values.slice(r*a,o*a)}return this}validate(){let t=!0,e=this.getValueSize();e-Math.floor(e)!==0&&(Dt("KeyframeTrack: Invalid value size in track.",this),t=!1);let n=this.times,i=this.values,r=n.length;r===0&&(Dt("KeyframeTrack: Track is empty.",this),t=!1);let o=null;for(let a=0;a!==r;a++){let c=n[a];if(typeof c=="number"&&isNaN(c)){Dt("KeyframeTrack: Time is not a valid number.",this,a,c),t=!1;break}if(o!==null&&o>c){Dt("KeyframeTrack: Out of order keys.",this,a,c,o),t=!1;break}o=c}if(i!==void 0&&Bm(i))for(let a=0,c=i.length;a!==c;++a){let l=i[a];if(isNaN(l)){Dt("KeyframeTrack: Value is not a valid number.",this,a,l),t=!1;break}}return t}optimize(){let t=this.times.slice(),e=this.values.slice(),n=this.getValueSize(),i=this.getInterpolation()===Ia,r=t.length-1,o=1;for(let a=1;a<r;++a){let c=!1,l=t[a],h=t[a+1];if(l!==h&&(a!==1||l!==t[0]))if(i)c=!0;else{let f=a*n,u=f-n,d=f+n;for(let g=0;g!==n;++g){let v=e[f+g];if(v!==e[u+g]||v!==e[d+g]){c=!0;break}}}if(c){if(a!==o){t[o]=t[a];let f=a*n,u=o*n;for(let d=0;d!==n;++d)e[u+d]=e[f+d]}++o}}if(r>0){t[o]=t[r];for(let a=r*n,c=o*n,l=0;l!==n;++l)e[c+l]=e[a+l];++o}return o!==t.length?(this.times=t.slice(0,o),this.values=e.slice(0,o*n)):(this.times=t,this.values=e),this}clone(){let t=this.times.slice(),e=this.values.slice(),n=this.constructor,i=new n(this.name,t,e);return i.createInterpolant=this.createInterpolant,Qr(this.settings)&&(i.settings={inTangents:this.settings.inTangents.slice(),outTangents:this.settings.outTangents.slice()}),i}};function sd(s,t){for(let e=0,n=s.length;e!==n;e+=2)s[e]+=t}function rd(s,t){for(let e=0,n=s.length;e!==n;e+=2)s[e]*=t}Mn.prototype.ValueTypeName="";Mn.prototype.TimeBufferType=Float32Array;Mn.prototype.ValueBufferType=Float32Array;Mn.prototype.DefaultInterpolation=gs;var Ci=class extends Mn{constructor(t,e,n){super(t,e,n)}};Ci.prototype.ValueTypeName="bool";Ci.prototype.ValueBufferType=Array;Ci.prototype.DefaultInterpolation=ms;Ci.prototype.InterpolantFactoryMethodLinear=void 0;Ci.prototype.InterpolantFactoryMethodSmooth=void 0;var vo=class extends Mn{constructor(t,e,n,i){super(t,e,n,i)}};vo.prototype.ValueTypeName="color";var Pi=class extends Mn{constructor(t,e,n,i){super(t,e,n,i)}};Pi.prototype.ValueTypeName="number";var Qa=class extends ni{constructor(t,e,n,i){super(t,e,n,i)}interpolate_(t,e,n,i){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,c=(n-e)/(i-e),l=t*a;for(let h=l+a;l!==h;l+=4)wn.slerpFlat(r,0,o,l-a,o,l,c);return r}},Ii=class extends Mn{constructor(t,e,n,i){super(t,e,n,i)}InterpolantFactoryMethodLinear(t){return new Qa(this.times,this.values,this.getValueSize(),t)}};Ii.prototype.ValueTypeName="quaternion";Ii.prototype.InterpolantFactoryMethodSmooth=void 0;var Li=class extends Mn{constructor(t,e,n){super(t,e,n)}};Li.prototype.ValueTypeName="string";Li.prototype.ValueBufferType=Array;Li.prototype.DefaultInterpolation=ms;Li.prototype.InterpolantFactoryMethodLinear=void 0;Li.prototype.InterpolantFactoryMethodSmooth=void 0;var Zi=class extends Mn{constructor(t,e,n,i){super(t,e,n,i)}};Zi.prototype.ValueTypeName="vector";var Mo=class{constructor(t="",e=-1,n=[],i=Bd){this.name=t,this.tracks=n,this.duration=e,this.blendMode=i,this.uuid=oi(),this.userData={},this.duration<0&&this.resetDuration()}static parse(t){let e=[],n=t.tracks,i=1/(t.fps||1);for(let o=0,a=n.length;o!==a;++o)e.push(Lg(n[o]).scale(i));let r=new this(t.name,t.duration,e,t.blendMode);return r.uuid=t.uuid,r.userData=JSON.parse(t.userData||"{}"),r}static toJSON(t){let e=[],n=t.tracks,i={name:t.name,duration:t.duration,tracks:e,uuid:t.uuid,blendMode:t.blendMode,userData:JSON.stringify(t.userData)};for(let r=0,o=n.length;r!==o;++r)e.push(Mn.toJSON(n[r]));return i}static CreateFromMorphTargetSequence(t,e,n,i){let r=e.length,o=[];for(let a=0;a<r;a++){let c=[],l=[];c.push((a+r-1)%r,a,(a+1)%r),l.push(0,1,0);let h=Eg(c);c=id(c,1,h),l=id(l,1,h),!i&&c[0]===0&&(c.push(r),l.push(l[0])),o.push(new Pi(".morphTargetInfluences["+e[a].name+"]",c,l).scale(1/n))}return new this(t,-1,o)}static findByName(t,e){let n=t;if(!Array.isArray(t)){let i=t;n=i.geometry&&i.geometry.animations||i.animations}for(let i=0;i<n.length;i++)if(n[i].name===e)return n[i];return null}static CreateClipsFromMorphTargetSequences(t,e,n){let i={},r=/^([\w-]*?)([\d]+)$/;for(let a=0,c=t.length;a<c;a++){let l=t[a],h=l.name.match(r);if(h&&h.length>1){let f=h[1],u=i[f];u||(i[f]=u=[]),u.push(l)}}let o=[];for(let a in i)o.push(this.CreateFromMorphTargetSequence(a,i[a],e,n));return o}resetDuration(){let t=this.tracks,e=0;for(let n=0,i=t.length;n!==i;++n){let r=this.tracks[n];e=Math.max(e,r.times[r.times.length-1])}return this.duration=e,this}trim(){for(let t=0;t<this.tracks.length;t++)this.tracks[t].trim(0,this.duration);return this}validate(){let t=!0;for(let e=0;e<this.tracks.length;e++)t=t&&this.tracks[e].validate();return t}optimize(){for(let t=0;t<this.tracks.length;t++)this.tracks[t].optimize();return this}clone(){let t=[];for(let n=0;n<this.tracks.length;n++)t.push(this.tracks[n].clone());let e=new this.constructor(this.name,this.duration,t,this.blendMode);return e.userData=JSON.parse(JSON.stringify(this.userData)),e}toJSON(){return this.constructor.toJSON(this)}};function Ig(s){switch(s.toLowerCase()){case"scalar":case"double":case"float":case"number":case"integer":return Pi;case"vector":case"vector2":case"vector3":case"vector4":return Zi;case"color":return vo;case"quaternion":return Ii;case"bool":case"boolean":return Ci;case"string":return Li}throw new Error("THREE.KeyframeTrack: Unsupported typeName: "+s)}function Lg(s){if(s.type===void 0)throw new Error("THREE.KeyframeTrack: track type undefined, can not parse");let t=Ig(s.type);if(s.times===void 0){let n=[],i=[];Rg(s.keys,n,i,"value"),s.times=n,s.values=i}let e;return t.parse!==void 0?e=t.parse(s):e=new t(s.name,s.times,s.values,s.interpolation),Qr(s.settings)&&(e.settings={inTangents:Yi(s.settings.inTangents,Float32Array),outTangents:Yi(s.settings.outTangents,Float32Array)}),e}var jn={enabled:!1,files:{},add:function(s,t){this.enabled!==!1&&(od(s)||(this.files[s]=t))},get:function(s){if(this.enabled!==!1&&!od(s))return this.files[s]},remove:function(s){delete this.files[s]},clear:function(){this.files={}}};function od(s){try{let t=s.slice(s.indexOf(":")+1);return new URL(t).protocol==="blob:"}catch{return!1}}var mr=class{constructor(t,e,n){let i=this,r=!1,o=0,a=0,c,l=[];this.onStart=void 0,this.onLoad=t,this.onProgress=e,this.onError=n,this._abortController=null,this.itemStart=function(h){a++,r===!1&&i.onStart!==void 0&&i.onStart(h,o,a),r=!0},this.itemEnd=function(h){o++,i.onProgress!==void 0&&i.onProgress(h,o,a),o===a&&(r=!1,i.onLoad!==void 0&&i.onLoad())},this.itemError=function(h){i.onError!==void 0&&i.onError(h)},this.resolveURL=function(h){return h=h.normalize("NFC"),c?c(h):h},this.setURLModifier=function(h){return c=h,this},this.addHandler=function(h,f){return l.push(h,f),this},this.removeHandler=function(h){let f=l.indexOf(h);return f!==-1&&l.splice(f,2),this},this.getHandler=function(h){for(let f=0,u=l.length;f<u;f+=2){let d=l[f],g=l[f+1];if(d.global&&(d.lastIndex=0),d.test(h))return g}return null},this.abort=function(){return this.abortController.abort(),this._abortController=null,this}}get abortController(){return this._abortController||(this._abortController=new AbortController),this._abortController}},tp=new mr,ii=class{constructor(t){this.manager=t!==void 0?t:tp,this.crossOrigin="anonymous",this.withCredentials=!1,this.path="",this.resourcePath="",this.requestHeader={},this.priority="auto",this.cache="default",typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}load(){}loadAsync(t,e){let n=this;return new Promise(function(i,r){n.load(t,i,e,r)})}parse(){}setCrossOrigin(t){return this.crossOrigin=t,this}setWithCredentials(t){return this.withCredentials=t,this}setPath(t){return this.path=t,this}setResourcePath(t){return this.resourcePath=t,this}setRequestHeader(t){return this.requestHeader=t,this}setPriority(t){return this.priority=t,this}setCache(t){return this.cache=t,this}abort(){return this}};ii.DEFAULT_MATERIAL_NAME="__DEFAULT";var vi={},fh=class extends Error{constructor(t,e){super(t),this.response=e}},gr=class extends ii{constructor(t){super(t),this.mimeType="",this.responseType="",this._abortController=new AbortController}load(t,e,n,i){t===void 0&&(t=""),this.path!==void 0&&(t=this.path+t),t=this.manager.resolveURL(t);let r=jn.get(`file:${t}`);if(r!==void 0){this.manager.itemStart(t),setTimeout(()=>{e&&e(r),this.manager.itemEnd(t)},0);return}if(vi[t]!==void 0){vi[t].push({onLoad:e,onProgress:n,onError:i});return}vi[t]=[],vi[t].push({onLoad:e,onProgress:n,onError:i});let o=new Request(t,{headers:new Headers(this.requestHeader),credentials:this.withCredentials?"include":"same-origin",priority:this.priority,cache:this.cache,signal:typeof AbortSignal.any=="function"?AbortSignal.any([this._abortController.signal,this.manager.abortController.signal]):this._abortController.signal}),a=this.mimeType,c=this.responseType;fetch(o).then(l=>{if(l.status===200||l.status===0){if(l.status===0&&Tt("FileLoader: HTTP Status 0 received."),typeof ReadableStream>"u"||l.body===void 0||l.body.getReader===void 0)return l;let h=vi[t],f=l.body.getReader(),u=l.headers.get("X-File-Size")||l.headers.get("Content-Length"),d=u?parseInt(u):0,g=d!==0,v=0,m=new ReadableStream({start(p){x();function x(){f.read().then(({done:M,value:y})=>{if(M)p.close();else{v+=y.byteLength;let S=new ProgressEvent("progress",{lengthComputable:g,loaded:v,total:d});for(let T=0,_=h.length;T<_;T++){let b=h[T];b.onProgress&&b.onProgress(S)}p.enqueue(y),x()}},M=>{p.error(M)})}}});return new Response(m)}else throw new fh(`fetch for "${l.url}" responded with ${l.status}: ${l.statusText}`,l)}).then(l=>{switch(c){case"arraybuffer":return l.arrayBuffer();case"blob":return l.blob();case"document":return l.text().then(h=>new DOMParser().parseFromString(h,a));case"json":return l.json();default:if(a==="")return l.text();{let f=/charset="?([^;"\s]*)"?/i.exec(a),u=f&&f[1]?f[1].toLowerCase():void 0,d=new TextDecoder(u);return l.arrayBuffer().then(g=>d.decode(g))}}}).then(l=>{jn.add(`file:${t}`,l);let h=vi[t];delete vi[t];for(let f=0,u=h.length;f<u;f++){let d=h[f];d.onLoad&&d.onLoad(l)}}).catch(l=>{let h=vi[t];if(h===void 0)throw this.manager.itemError(t),l;delete vi[t];for(let f=0,u=h.length;f<u;f++){let d=h[f];d.onError&&d.onError(l)}this.manager.itemError(t)}).finally(()=>{this.manager.itemEnd(t)}),this.manager.itemStart(t)}setResponseType(t){return this.responseType=t,this}setMimeType(t){return this.mimeType=t,this}abort(){return this._abortController.abort(),this._abortController=new AbortController,this}};var Ks=new WeakMap,tc=class extends ii{constructor(t){super(t)}load(t,e,n,i){this.path!==void 0&&(t=this.path+t),t=this.manager.resolveURL(t);let r=this,o=jn.get(`image:${t}`);if(o!==void 0){if(o.complete===!0)r.manager.itemStart(t),setTimeout(function(){e&&e(o),r.manager.itemEnd(t)},0);else{let f=Ks.get(o);f===void 0&&(f=[],Ks.set(o,f)),f.push({onLoad:e,onError:i})}return o}let a=ir("img");function c(){h(),e&&e(this);let f=Ks.get(this)||[];for(let u=0;u<f.length;u++){let d=f[u];d.onLoad&&d.onLoad(this)}Ks.delete(this),r.manager.itemEnd(t)}function l(f){h(),i&&i(f),jn.remove(`image:${t}`);let u=Ks.get(this)||[];for(let d=0;d<u.length;d++){let g=u[d];g.onError&&g.onError(f)}Ks.delete(this),r.manager.itemError(t),r.manager.itemEnd(t)}function h(){a.removeEventListener("load",c,!1),a.removeEventListener("error",l,!1)}return a.addEventListener("load",c,!1),a.addEventListener("error",l,!1),t.slice(0,5)!=="data:"&&this.crossOrigin!==void 0&&(a.crossOrigin=this.crossOrigin),jn.add(`image:${t}`,a),r.manager.itemStart(t),a.fetchPriority=this.priority,a.src=t,a}};var si=class extends ii{constructor(t){super(t)}load(t,e,n,i){let r=new ke,o=new tc(this.manager);return o.setPriority(this.priority),o.setCache(this.cache),o.setCrossOrigin(this.crossOrigin),o.setPath(this.path),o.load(t,function(a){r.image=a,r.needsUpdate=!0,e!==void 0&&e(r)},n,i),r}},vs=class extends Ae{static registerNode(t){this.prototype._lightNode=t}constructor(t,e=1){super(),this.isLight=!0,this.type="Light",this.color=new Pt(t),this.intensity=e}copy(t,e){return super.copy(t,e),this.color.copy(t.color),this.intensity=t.intensity,this}toJSON(t){let e=super.toJSON(t);return e.object.color=this.color.getHex(),e.object.intensity=this.intensity,e}};var ih=new _t,ad=new R,cd=new R,_r=class{constructor(t){this.camera=t,this.intensity=1,this.bias=0,this.biasNode=null,this.normalBias=0,this.radius=1,this.blurSamples=8,this.mapSize=new At(512,512),this.mapType=an,this.map=null,this.mapPass=null,this.matrix=new _t,this.autoUpdate=!0,this.needsUpdate=!1,this._frustum=new Ki,this._frameExtents=new At(1,1),this._viewportCount=1,this._viewports=[new Zt(0,0,1,1)]}getViewportCount(){return this._viewportCount}getCamera(){return this.camera}getFrustum(){return this._frustum}updateMatrices(t){let e=this.camera;ad.setFromMatrixPosition(t.matrixWorld),e.position.copy(ad),cd.setFromMatrixPosition(t.target.matrixWorld),e.lookAt(cd),e.updateMatrixWorld(),this._updateMatrix(e,this.matrix,this._frustum)}_updateMatrix(t,e,n,i){ih.multiplyMatrices(t.projectionMatrix,t.matrixWorldInverse),n.setFromProjectionMatrix(ih,t.coordinateSystem,t.reversedDepth);let r=this._frameExtents,o=i?i.z/r.x:1,a=i?i.w/r.y:1,c=i?i.x/r.x:0,l=i?i.y/r.y:0;t.coordinateSystem===nr||t.reversedDepth?e.set(.5*o,0,0,.5*o+c,0,.5*a,0,.5*a+l,0,0,1,0,0,0,0,1):e.set(.5*o,0,0,.5*o+c,0,.5*a,0,.5*a+l,0,0,.5,.5,0,0,0,1),e.multiply(ih)}getViewport(t){return this._viewports[t]}getFrameExtents(){return this._frameExtents}dispose(){this.map&&this.map.dispose(),this.mapPass&&this.mapPass.dispose()}copy(t){return this.camera=t.camera.clone(),this.intensity=t.intensity,this.bias=t.bias,this.radius=t.radius,this.autoUpdate=t.autoUpdate,this.needsUpdate=t.needsUpdate,this.normalBias=t.normalBias,this.blurSamples=t.blurSamples,this.mapSize.copy(t.mapSize),this.mapType=t.mapType,this.biasNode=t.biasNode,this}clone(){return new this.constructor().copy(this)}toJSON(){let t={};return t.intensity=this.intensity,t.bias=this.bias,t.normalBias=this.normalBias,t.radius=this.radius,t.blurSamples=this.blurSamples,t.mapSize=this.mapSize.toArray(),t.mapType=this.mapType,t.camera=this.camera.toJSON(!1).object,delete t.camera.matrix,t}},Ra=new R,Ca=new wn,$n=new R,So=class extends Ae{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new _t,this.projectionMatrix=new _t,this.projectionMatrixInverse=new _t,this.coordinateSystem=Dn,this._reversedDepth=!1}get reversedDepth(){return this._reversedDepth}copy(t,e){return super.copy(t,e),this.matrixWorldInverse.copy(t.matrixWorldInverse),this.projectionMatrix.copy(t.projectionMatrix),this.projectionMatrixInverse.copy(t.projectionMatrixInverse),this.coordinateSystem=t.coordinateSystem,this}getWorldDirection(t){return super.getWorldDirection(t).negate()}updateMatrixWorld(t){super.updateMatrixWorld(t),this.matrixWorld.decompose(Ra,Ca,$n),$n.x===1&&$n.y===1&&$n.z===1?this.matrixWorldInverse.copy(this.matrixWorld).invert():this.matrixWorldInverse.compose(Ra,Ca,$n.set(1,1,1)).invert()}updateWorldMatrix(t,e,n=!1){super.updateWorldMatrix(t,e,n),this.matrixWorld.decompose(Ra,Ca,$n),$n.x===1&&$n.y===1&&$n.z===1?this.matrixWorldInverse.copy(this.matrixWorld).invert():this.matrixWorldInverse.compose(Ra,Ca,$n.set(1,1,1)).invert()}clone(){return new this.constructor().copy(this)}},qi=new R,ld=new At,hd=new At,Le=class extends So{constructor(t=50,e=1,n=.1,i=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=t,this.zoom=1,this.near=n,this.far=i,this.focus=10,this.aspect=e,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.fov=t.fov,this.zoom=t.zoom,this.near=t.near,this.far=t.far,this.focus=t.focus,this.aspect=t.aspect,this.view=t.view===null?null:Object.assign({},t.view),this.filmGauge=t.filmGauge,this.filmOffset=t.filmOffset,this}setFocalLength(t){let e=.5*this.getFilmHeight()/t;this.fov=_s*2*Math.atan(e),this.updateProjectionMatrix()}getFocalLength(){let t=Math.tan(to*.5*this.fov);return .5*this.getFilmHeight()/t}getEffectiveFOV(){return _s*2*Math.atan(Math.tan(to*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}getViewBounds(t,e,n){qi.set(-1,-1,.5).applyMatrix4(this.projectionMatrixInverse),e.set(qi.x,qi.y).multiplyScalar(-t/qi.z),qi.set(1,1,.5).applyMatrix4(this.projectionMatrixInverse),n.set(qi.x,qi.y).multiplyScalar(-t/qi.z)}getViewSize(t,e){return this.getViewBounds(t,ld,hd),e.subVectors(hd,ld)}setViewOffset(t,e,n,i,r,o){this.aspect=t/e,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=i,this.view.width=r,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){let t=this.near,e=t*Math.tan(to*.5*this.fov)/this.zoom,n=2*e,i=this.aspect*n,r=-.5*i,o=this.view;if(this.view!==null&&this.view.enabled){let c=o.fullWidth,l=o.fullHeight;r+=o.offsetX*i/c,e-=o.offsetY*n/l,i*=o.width/c,n*=o.height/l}let a=this.filmOffset;a!==0&&(r+=t*a/this.getFilmWidth()),this.projectionMatrix.makePerspective(r,r+i,e,e-n,t,this.far,this.coordinateSystem,this.reversedDepth),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){let e=super.toJSON(t);return e.object.fov=this.fov,e.object.zoom=this.zoom,e.object.near=this.near,e.object.far=this.far,e.object.focus=this.focus,e.object.aspect=this.aspect,this.view!==null&&(e.object.view=Object.assign({},this.view)),e.object.filmGauge=this.filmGauge,e.object.filmOffset=this.filmOffset,e}},dh=class extends _r{constructor(){super(new Le(50,1,.5,500)),this.isSpotLightShadow=!0,this.focus=1,this.aspect=1}updateMatrices(t){let e=this.camera,n=_s*2*t.angle*this.focus,i=this.mapSize.width/this.mapSize.height*this.aspect,r=t.distance||e.far;(n!==e.fov||i!==e.aspect||r!==e.far)&&(e.fov=n,e.aspect=i,e.far=r,e.updateProjectionMatrix()),super.updateMatrices(t)}copy(t){return super.copy(t),this.focus=t.focus,this.aspect=t.aspect,this}toJSON(){let t=super.toJSON();return t.focus=this.focus,t.aspect=this.aspect,t}},Ms=class extends vs{constructor(t,e,n=0,i=Math.PI/3,r=0,o=2){super(t,e),this.isSpotLight=!0,this.type="SpotLight",this.position.copy(Ae.DEFAULT_UP),this.updateMatrix(),this.target=new Ae,this.distance=n,this.angle=i,this.penumbra=r,this.decay=o,this.map=null,this.shadow=new dh}get power(){return this.intensity*Math.PI}set power(t){this.intensity=t/Math.PI}dispose(){super.dispose(),this.shadow.dispose()}copy(t,e){return super.copy(t,e),this.distance=t.distance,this.angle=t.angle,this.penumbra=t.penumbra,this.decay=t.decay,this.target=t.target.clone(),this.map=t.map,this.shadow=t.shadow.clone(),this}toJSON(t){let e=super.toJSON(t);return e.object.distance=this.distance,e.object.angle=this.angle,e.object.decay=this.decay,e.object.penumbra=this.penumbra,e.object.target=this.target.uuid,this.map&&this.map.isTexture&&(e.object.map=this.map.toJSON(t).uuid),e.object.shadow=this.shadow.toJSON(),e}},ph=class extends _r{constructor(){super(new Le(90,1,.5,500)),this.isPointLightShadow=!0}},Ss=class extends vs{constructor(t,e,n=0,i=2){super(t,e),this.isPointLight=!0,this.type="PointLight",this.distance=n,this.decay=i,this.shadow=new ph}get power(){return this.intensity*4*Math.PI}set power(t){this.intensity=t/(4*Math.PI)}dispose(){super.dispose(),this.shadow.dispose()}copy(t,e){return super.copy(t,e),this.distance=t.distance,this.decay=t.decay,this.shadow=t.shadow.clone(),this}toJSON(t){let e=super.toJSON(t);return e.object.distance=this.distance,e.object.decay=this.decay,e.object.shadow=this.shadow.toJSON(),e}},qn=class extends So{constructor(t=-1,e=1,n=1,i=-1,r=.1,o=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=t,this.right=e,this.top=n,this.bottom=i,this.near=r,this.far=o,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.left=t.left,this.right=t.right,this.top=t.top,this.bottom=t.bottom,this.near=t.near,this.far=t.far,this.zoom=t.zoom,this.view=t.view===null?null:Object.assign({},t.view),this}setViewOffset(t,e,n,i,r,o){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=i,this.view.width=r,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){let t=(this.right-this.left)/(2*this.zoom),e=(this.top-this.bottom)/(2*this.zoom),n=(this.right+this.left)/2,i=(this.top+this.bottom)/2,r=n-t,o=n+t,a=i+e,c=i-e;if(this.view!==null&&this.view.enabled){let l=(this.right-this.left)/this.view.fullWidth/this.zoom,h=(this.top-this.bottom)/this.view.fullHeight/this.zoom;r+=l*this.view.offsetX,o=r+l*this.view.width,a-=h*this.view.offsetY,c=a-h*this.view.height}this.projectionMatrix.makeOrthographic(r,o,a,c,this.near,this.far,this.coordinateSystem,this.reversedDepth),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){let e=super.toJSON(t);return e.object.zoom=this.zoom,e.object.left=this.left,e.object.right=this.right,e.object.top=this.top,e.object.bottom=this.bottom,e.object.near=this.near,e.object.far=this.far,this.view!==null&&(e.object.view=Object.assign({},this.view)),e}},mh=class extends _r{constructor(){super(new qn(-5,5,5,-5,.5,500)),this.isDirectionalLightShadow=!0}},bs=class extends vs{constructor(t,e){super(t,e),this.isDirectionalLight=!0,this.type="DirectionalLight",this.position.copy(Ae.DEFAULT_UP),this.updateMatrix(),this.target=new Ae,this.shadow=new mh}dispose(){super.dispose(),this.shadow.dispose()}copy(t){return super.copy(t),this.target=t.target.clone(),this.shadow=t.shadow.clone(),this}toJSON(t){let e=super.toJSON(t);return e.object.shadow=this.shadow.toJSON(),e.object.target=this.target.uuid,e}},bo=class extends vs{constructor(t,e){super(t,e),this.isAmbientLight=!0,this.type="AmbientLight"}};var Ni=class{static extractUrlBase(t){let e=t.lastIndexOf("/");return e===-1?"./":t.slice(0,e+1)}static resolveURL(t,e){return typeof t!="string"||t===""?"":(/^https?:\/\//i.test(e)&&/^\//.test(t)&&(e=e.replace(/(^https?:\/\/[^\/]+).*/i,"$1")),/^(https?:)?\/\//i.test(t)||/^data:.*,.*$/i.test(t)||/^blob:.*$/i.test(t)?t:e+t)}};var sh=new WeakMap,To=class extends ii{constructor(t){super(t),this.isImageBitmapLoader=!0,typeof createImageBitmap>"u"&&Tt("ImageBitmapLoader: createImageBitmap() not supported."),typeof fetch>"u"&&Tt("ImageBitmapLoader: fetch() not supported."),this.options={premultiplyAlpha:"none"},this._abortController=new AbortController}setOptions(t){return this.options=t,this}load(t,e,n,i){t===void 0&&(t=""),this.path!==void 0&&(t=this.path+t),t=this.manager.resolveURL(t);let r=this,o=jn.get(`image-bitmap:${t}`);if(o!==void 0){if(r.manager.itemStart(t),o.then){o.then(l=>{sh.has(o)===!0?(i&&i(sh.get(o)),r.manager.itemError(t),r.manager.itemEnd(t)):(e&&e(l),r.manager.itemEnd(t))});return}setTimeout(function(){e&&e(o),r.manager.itemEnd(t)},0);return}let a={};a.credentials=this.withCredentials||this.crossOrigin!=="anonymous"?"include":"same-origin",a.headers=this.requestHeader,a.priority=this.priority,a.cache=this.cache,a.signal=typeof AbortSignal.any=="function"?AbortSignal.any([this._abortController.signal,this.manager.abortController.signal]):this._abortController.signal;let c=fetch(t,a).then(function(l){return l.blob()}).then(function(l){return createImageBitmap(l,Object.assign({},r.options,{colorSpaceConversion:"none"}))}).then(function(l){return jn.add(`image-bitmap:${t}`,l),e&&e(l),r.manager.itemEnd(t),l}).catch(function(l){i&&i(l),sh.set(c,l),jn.remove(`image-bitmap:${t}`),r.manager.itemError(t),r.manager.itemEnd(t)});jn.add(`image-bitmap:${t}`,c),r.manager.itemStart(t)}abort(){return this._abortController.abort(),this._abortController=new AbortController,this}};var Zs=-90,Js=1,Ji=class extends Ae{constructor(t,e,n){super(),this.type="CubeCamera",this.renderTarget=n,this.coordinateSystem=null,this.activeMipmapLevel=0;let i=new Le(Zs,Js,t,e);i.layers=this.layers,this.add(i);let r=new Le(Zs,Js,t,e);r.layers=this.layers,this.add(r);let o=new Le(Zs,Js,t,e);o.layers=this.layers,this.add(o);let a=new Le(Zs,Js,t,e);a.layers=this.layers,this.add(a);let c=new Le(Zs,Js,t,e);c.layers=this.layers,this.add(c);let l=new Le(Zs,Js,t,e);l.layers=this.layers,this.add(l)}updateCoordinateSystem(){let t=this.coordinateSystem,e=this.children.concat(),[n,i,r,o,a,c]=e;for(let l of e)this.remove(l);if(t===Dn)n.up.set(0,1,0),n.lookAt(1,0,0),i.up.set(0,1,0),i.lookAt(-1,0,0),r.up.set(0,0,-1),r.lookAt(0,1,0),o.up.set(0,0,1),o.lookAt(0,-1,0),a.up.set(0,1,0),a.lookAt(0,0,1),c.up.set(0,1,0),c.lookAt(0,0,-1);else if(t===nr)n.up.set(0,-1,0),n.lookAt(-1,0,0),i.up.set(0,-1,0),i.lookAt(1,0,0),r.up.set(0,0,1),r.lookAt(0,1,0),o.up.set(0,0,-1),o.lookAt(0,-1,0),a.up.set(0,-1,0),a.lookAt(0,0,1),c.up.set(0,-1,0),c.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+t);for(let l of e)this.add(l),l.updateMatrixWorld()}update(t,e){this.parent===null&&this.updateMatrixWorld();let{renderTarget:n,activeMipmapLevel:i}=this;this.coordinateSystem!==t.coordinateSystem&&(this.coordinateSystem=t.coordinateSystem,this.updateCoordinateSystem());let[r,o,a,c,l,h]=this.children,f=t.getRenderTarget(),u=t.getActiveCubeFace(),d=t.getActiveMipmapLevel(),g=t.xr.enabled;t.xr.enabled=!1;let v=n.texture.mipmapsAutoUpdate;n.texture.mipmapsAutoUpdate=!1;let m=!1;t.isWebGLRenderer===!0?m=t.state.buffers.depth.getReversed():m=t.reversedDepthBuffer,t.setRenderTarget(n,0,i),m&&t.autoClear===!1&&t.clearDepth(),t.render(e,r),t.setRenderTarget(n,1,i),m&&t.autoClear===!1&&t.clearDepth(),t.render(e,o),t.setRenderTarget(n,2,i),m&&t.autoClear===!1&&t.clearDepth(),t.render(e,a),t.setRenderTarget(n,3,i),m&&t.autoClear===!1&&t.clearDepth(),t.render(e,c),t.setRenderTarget(n,4,i),m&&t.autoClear===!1&&t.clearDepth(),t.render(e,l),n.texture.mipmapsAutoUpdate=v,t.setRenderTarget(n,5,i),m&&t.autoClear===!1&&t.clearDepth(),t.render(e,h),t.setRenderTarget(f,u,d),t.xr.enabled=g,n.texture.needsPMREMUpdate=!0}},ec=class extends Le{constructor(t=[]){super(),this.isArrayCamera=!0,this.isMultiViewCamera=!1,this.cameras=t,this.perCameraFrustumCulled=!1}},wo=class{constructor(){this._previousTime=0,this._currentTime=0,this._startTime=performance.now(),this._delta=0,this._elapsed=0,this._timescale=1,this._document=null,this._pageVisibilityHandler=null}connect(t){this._document=t,t.hidden!==void 0&&(this._pageVisibilityHandler=Ng.bind(this),t.addEventListener("visibilitychange",this._pageVisibilityHandler,!1))}disconnect(){this._pageVisibilityHandler!==null&&(this._document.removeEventListener("visibilitychange",this._pageVisibilityHandler),this._pageVisibilityHandler=null),this._document=null}getDelta(){return this._delta/1e3}getElapsed(){return this._elapsed/1e3}getTimescale(){return this._timescale}setTimescale(t){return this._timescale=t,this}reset(){return this._currentTime=performance.now()-this._startTime,this}dispose(){this.disconnect()}update(t){return this._pageVisibilityHandler!==null&&this._document.hidden===!0?this._delta=0:(this._previousTime=this._currentTime,this._currentTime=(t!==void 0?t:performance.now())-this._startTime,this._delta=(this._currentTime-this._previousTime)*this._timescale,this._elapsed+=this._delta),this}};function Ng(){this._document.hidden===!1&&this.reset()}var Xh="\\[\\]\\.:\\/",Dg=new RegExp("["+Xh+"]","g"),qh="[^"+Xh+"]",Ug="[^"+Xh.replace("\\.","")+"]",Fg=/((?:WC+[\/:])*)/.source.replace("WC",qh),Og=/(WCOD+)?/.source.replace("WCOD",Ug),Bg=/(?:\.(WC+)(?:\[(.+)\])?)?/.source.replace("WC",qh),zg=/\.(WC+)(?:\[(.+)\])?/.source.replace("WC",qh),kg=new RegExp("^"+Fg+Og+Bg+zg+"$"),Vg=["material","materials","bones","map"],gh=class{constructor(t,e,n){let i=n||ue.parseTrackName(e);this._targetGroup=t,this._bindings=t.subscribe_(e,i)}getValue(t,e){this.bind();let n=this._targetGroup.nCachedObjects_,i=this._bindings[n];i!==void 0&&i.getValue(t,e)}setValue(t,e){let n=this._bindings;for(let i=this._targetGroup.nCachedObjects_,r=n.length;i!==r;++i)n[i].setValue(t,e)}bind(){let t=this._bindings;for(let e=this._targetGroup.nCachedObjects_,n=t.length;e!==n;++e)t[e].bind()}unbind(){let t=this._bindings;for(let e=this._targetGroup.nCachedObjects_,n=t.length;e!==n;++e)t[e].unbind()}},ue=class s{constructor(t,e,n){this.path=e,this.parsedPath=n||s.parseTrackName(e),this.node=s.findNode(t,this.parsedPath.nodeName),this.rootNode=t,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}static create(t,e,n){return t&&t.isAnimationObjectGroup?new s.Composite(t,e,n):new s(t,e,n)}static sanitizeNodeName(t){return t.replace(/\s/g,"_").replace(Dg,"")}static parseTrackName(t){let e=kg.exec(t);if(e===null)throw new Error("THREE.PropertyBinding: Cannot parse trackName: "+t);let n={nodeName:e[2],objectName:e[3],objectIndex:e[4],propertyName:e[5],propertyIndex:e[6]},i=n.nodeName&&n.nodeName.lastIndexOf(".");if(i!==void 0&&i!==-1){let r=n.nodeName.substring(i+1);Vg.indexOf(r)!==-1&&(n.nodeName=n.nodeName.substring(0,i),n.objectName=r)}if(n.propertyName===null||n.propertyName.length===0)throw new Error("THREE.PropertyBinding: can not parse propertyName from trackName: "+t);return n}static findNode(t,e){if(e===void 0||e===""||e==="."||e===-1||e===t.name||e===t.uuid)return t;if(t.skeleton){let n=t.skeleton.getBoneByName(e);if(n!==void 0)return n}if(t.children){let n=function(r){for(let o=0;o<r.length;o++){let a=r[o];if(a.name===e||a.uuid===e)return a;let c=n(a.children);if(c)return c}return null},i=n(t.children);if(i)return i}return null}_getValue_unavailable(){}_setValue_unavailable(){}_getValue_direct(t,e){t[e]=this.targetObject[this.propertyName]}_getValue_array(t,e){let n=this.resolvedProperty;for(let i=0,r=n.length;i!==r;++i)t[e++]=n[i]}_getValue_arrayElement(t,e){t[e]=this.resolvedProperty[this.propertyIndex]}_getValue_toArray(t,e){this.resolvedProperty.toArray(t,e)}_setValue_direct(t,e){this.targetObject[this.propertyName]=t[e]}_setValue_direct_setNeedsUpdate(t,e){this.targetObject[this.propertyName]=t[e],this.targetObject.needsUpdate=!0}_setValue_direct_setMatrixWorldNeedsUpdate(t,e){this.targetObject[this.propertyName]=t[e],this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_array(t,e){let n=this.resolvedProperty;for(let i=0,r=n.length;i!==r;++i)n[i]=t[e++]}_setValue_array_setNeedsUpdate(t,e){let n=this.resolvedProperty;for(let i=0,r=n.length;i!==r;++i)n[i]=t[e++];this.targetObject.needsUpdate=!0}_setValue_array_setMatrixWorldNeedsUpdate(t,e){let n=this.resolvedProperty;for(let i=0,r=n.length;i!==r;++i)n[i]=t[e++];this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_arrayElement(t,e){this.resolvedProperty[this.propertyIndex]=t[e]}_setValue_arrayElement_setNeedsUpdate(t,e){this.resolvedProperty[this.propertyIndex]=t[e],this.targetObject.needsUpdate=!0}_setValue_arrayElement_setMatrixWorldNeedsUpdate(t,e){this.resolvedProperty[this.propertyIndex]=t[e],this.targetObject.matrixWorldNeedsUpdate=!0}_setValue_fromArray(t,e){this.resolvedProperty.fromArray(t,e)}_setValue_fromArray_setNeedsUpdate(t,e){this.resolvedProperty.fromArray(t,e),this.targetObject.needsUpdate=!0}_setValue_fromArray_setMatrixWorldNeedsUpdate(t,e){this.resolvedProperty.fromArray(t,e),this.targetObject.matrixWorldNeedsUpdate=!0}_getValue_unbound(t,e){this.bind(),this.getValue(t,e)}_setValue_unbound(t,e){this.bind(),this.setValue(t,e)}bind(){let t=this.node,e=this.parsedPath,n=e.objectName,i=e.propertyName,r=e.propertyIndex;if(t||(t=s.findNode(this.rootNode,e.nodeName),this.node=t),this.getValue=this._getValue_unavailable,this.setValue=this._setValue_unavailable,!t){Tt("PropertyBinding: No target node found for track: "+this.path+".");return}if(n){let l=e.objectIndex;switch(n){case"materials":if(!t.material){Dt("PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!t.material.materials){Dt("PropertyBinding: Can not bind to material.materials as node.material does not have a materials array.",this);return}t=t.material.materials;break;case"bones":if(!t.skeleton){Dt("PropertyBinding: Can not bind to bones as node does not have a skeleton.",this);return}t=t.skeleton.bones;for(let h=0;h<t.length;h++)if(t[h].name===l){l=h;break}break;case"map":if("map"in t){t=t.map;break}if(!t.material){Dt("PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!t.material.map){Dt("PropertyBinding: Can not bind to material.map as node.material does not have a map.",this);return}t=t.material.map;break;default:if(t[n]===void 0){Dt("PropertyBinding: Can not bind to objectName of node undefined.",this);return}t=t[n]}if(l!==void 0){if(t[l]===void 0){Dt("PropertyBinding: Trying to bind to objectIndex of objectName, but is undefined.",this,t);return}t=t[l]}}let o=t[i];if(o===void 0){let l=e.nodeName;Dt("PropertyBinding: Trying to update property for track: "+l+"."+i+" but it wasn't found.",t);return}let a=this.Versioning.None;this.targetObject=t,t.isMaterial===!0?a=this.Versioning.NeedsUpdate:t.isObject3D===!0&&(a=this.Versioning.MatrixWorldNeedsUpdate);let c=this.BindingType.Direct;if(r!==void 0){if(i==="morphTargetInfluences"){if(!t.geometry){Dt("PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.",this);return}if(!t.geometry.morphAttributes){Dt("PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.morphAttributes.",this);return}t.morphTargetDictionary[r]!==void 0&&(r=t.morphTargetDictionary[r])}c=this.BindingType.ArrayElement,this.resolvedProperty=o,this.propertyIndex=r}else o.fromArray!==void 0&&o.toArray!==void 0?(c=this.BindingType.HasFromToArray,this.resolvedProperty=o):Array.isArray(o)?(c=this.BindingType.EntireArray,this.resolvedProperty=o):this.propertyName=i;this.getValue=this.GetterByBindingType[c],this.setValue=this.SetterByBindingTypeAndVersioning[c][a]}unbind(){this.node=null,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}};ue.Composite=gh;ue.prototype.BindingType={Direct:0,EntireArray:1,ArrayElement:2,HasFromToArray:3};ue.prototype.Versioning={None:0,NeedsUpdate:1,MatrixWorldNeedsUpdate:2};ue.prototype.GetterByBindingType=[ue.prototype._getValue_direct,ue.prototype._getValue_array,ue.prototype._getValue_arrayElement,ue.prototype._getValue_toArray];ue.prototype.SetterByBindingTypeAndVersioning=[[ue.prototype._setValue_direct,ue.prototype._setValue_direct_setNeedsUpdate,ue.prototype._setValue_direct_setMatrixWorldNeedsUpdate],[ue.prototype._setValue_array,ue.prototype._setValue_array_setNeedsUpdate,ue.prototype._setValue_array_setMatrixWorldNeedsUpdate],[ue.prototype._setValue_arrayElement,ue.prototype._setValue_arrayElement_setNeedsUpdate,ue.prototype._setValue_arrayElement_setMatrixWorldNeedsUpdate],[ue.prototype._setValue_fromArray,ue.prototype._setValue_fromArray_setNeedsUpdate,ue.prototype._setValue_fromArray_setMatrixWorldNeedsUpdate]];var PM=new Float32Array(1);var ud=new _t,Ao=class{constructor(t,e,n=0,i=1/0){this.ray=new ti(t,e),this.near=n,this.far=i,this.camera=null,this.layers=new or,this.params={Mesh:{},Line:{threshold:1},LOD:{},Points:{threshold:1},Sprite:{}}}set(t,e){this.ray.set(t,e)}setFromCamera(t,e){e.isPerspectiveCamera?(this.ray.origin.setFromMatrixPosition(e.matrixWorld),this.ray.direction.set(t.x,t.y,.5).unproject(e).sub(this.ray.origin).normalize(),this.camera=e):e.isOrthographicCamera?(this.ray.origin.set(t.x,t.y,e.projectionMatrix.elements[14]).unproject(e),this.ray.direction.set(0,0,-1).transformDirection(e.matrixWorld),this.camera=e):Dt("Raycaster: Unsupported camera type: "+e.type)}setFromXRController(t){return ud.identity().extractRotation(t.matrixWorld),this.ray.origin.setFromMatrixPosition(t.matrixWorld),this.ray.direction.set(0,0,-1).applyMatrix4(ud),this}intersectObject(t,e=!0,n=[]){return _h(t,this,n,e),n.sort(fd),n}intersectObjects(t,e=!0,n=[]){for(let i=0,r=t.length;i<r;i++)_h(t[i],this,n,e);return n.sort(fd),n}};function fd(s,t){return s.distance-t.distance}function _h(s,t,e,n){let i=!0;if(s.layers.test(t.layers)&&s.raycast(t,e)===!1&&(i=!1),i===!0&&n===!0){let r=s.children;for(let o=0,a=r.length;o<a;o++)_h(r[o],t,e,!0)}}var jh=class jh{constructor(t,e,n,i){this.elements=[1,0,0,1],t!==void 0&&this.set(t,e,n,i)}identity(){return this.set(1,0,0,1),this}fromArray(t,e=0){for(let n=0;n<4;n++)this.elements[n]=t[n+e];return this}set(t,e,n,i){let r=this.elements;return r[0]=t,r[2]=e,r[1]=n,r[3]=i,this}};jh.prototype.isMatrix2=!0;var xh=jh;var dd=new R,Pa=new R,$s=new R,js=new R,rh=new R,Gg=new R,Hg=new R,Qe=class{constructor(t=new R,e=new R){this.start=t,this.end=e}set(t,e){return this.start.copy(t),this.end.copy(e),this}copy(t){return this.start.copy(t.start),this.end.copy(t.end),this}getCenter(t){return t.addVectors(this.start,this.end).multiplyScalar(.5)}delta(t){return t.subVectors(this.end,this.start)}distanceSq(){return this.start.distanceToSquared(this.end)}distance(){return this.start.distanceTo(this.end)}at(t,e){return this.delta(e).multiplyScalar(t).add(this.start)}closestPointToPointParameter(t,e){dd.subVectors(t,this.start),Pa.subVectors(this.end,this.start);let n=Pa.dot(Pa);if(n===0)return 0;let r=Pa.dot(dd)/n;return e&&(r=kt(r,0,1)),r}closestPointToPoint(t,e,n){let i=this.closestPointToPointParameter(t,e);return this.delta(n).multiplyScalar(i).add(this.start)}distanceSqToLine3(t,e=Gg,n=Hg){let i=10000000000000001e-32,r,o,a=this.start,c=t.start,l=this.end,h=t.end;$s.subVectors(l,a),js.subVectors(h,c),rh.subVectors(a,c);let f=$s.dot($s),u=js.dot(js),d=js.dot(rh);if(f<=i&&u<=i)return e.copy(a),n.copy(c),e.distanceToSquared(n);if(f<=i)r=0,o=d/u,o=kt(o,0,1);else{let g=$s.dot(rh);if(u<=i)o=0,r=kt(-g/f,0,1);else{let v=$s.dot(js),m=f*u-v*v;m!==0?r=kt((v*d-g*u)/m,0,1):r=0,o=(v*r+d)/u,o<0?(o=0,r=kt(-g/f,0,1)):o>1&&(o=1,r=kt((v-g)/f,0,1))}}return e.copy(a).addScaledVector($s,r),n.copy(c).addScaledVector(js,o),e.distanceToSquared(n)}applyMatrix4(t){return this.start.applyMatrix4(t),this.end.applyMatrix4(t),this}equals(t){return t.start.equals(this.start)&&t.end.equals(this.end)}clone(){return new this.constructor().copy(this)}};function Yh(s,t,e,n){let i=Wg(n);switch(e){case Lh:return s*t;case cc:return s*t/i.components*i.byteLength;case lc:return s*t/i.components*i.byteLength;case $i:return s*t*2/i.components*i.byteLength;case hc:return s*t*2/i.components*i.byteLength;case Nh:return s*t*3/i.components*i.byteLength;case Fn:return s*t*4/i.components*i.byteLength;case uc:return s*t*4/i.components*i.byteLength;case No:case Do:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*8;case Uo:case Fo:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*16;case dc:case mc:return Math.max(s,16)*Math.max(t,8)/4;case fc:case pc:return Math.max(s,8)*Math.max(t,8)/2;case gc:case _c:case yc:case vc:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*8;case xc:case Oo:case Mc:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*16;case Sc:return Math.floor((s+3)/4)*Math.floor((t+3)/4)*16;case bc:return Math.floor((s+4)/5)*Math.floor((t+3)/4)*16;case Tc:return Math.floor((s+4)/5)*Math.floor((t+4)/5)*16;case wc:return Math.floor((s+5)/6)*Math.floor((t+4)/5)*16;case Ac:return Math.floor((s+5)/6)*Math.floor((t+5)/6)*16;case Ec:return Math.floor((s+7)/8)*Math.floor((t+4)/5)*16;case Rc:return Math.floor((s+7)/8)*Math.floor((t+5)/6)*16;case Cc:return Math.floor((s+7)/8)*Math.floor((t+7)/8)*16;case Pc:return Math.floor((s+9)/10)*Math.floor((t+4)/5)*16;case Ic:return Math.floor((s+9)/10)*Math.floor((t+5)/6)*16;case Lc:return Math.floor((s+9)/10)*Math.floor((t+7)/8)*16;case Nc:return Math.floor((s+9)/10)*Math.floor((t+9)/10)*16;case Dc:return Math.floor((s+11)/12)*Math.floor((t+9)/10)*16;case Uc:return Math.floor((s+11)/12)*Math.floor((t+11)/12)*16;case Fc:case Oc:case Bc:return Math.ceil(s/4)*Math.ceil(t/4)*16;case zc:case kc:return Math.ceil(s/4)*Math.ceil(t/4)*8;case Bo:case Vc:return Math.ceil(s/4)*Math.ceil(t/4)*16}throw new Error(`Unable to determine texture byte length for ${e} format.`)}function Wg(s){switch(s){case an:case Rh:return{byteLength:1,components:1};case Tr:case Ch:case cn:return{byteLength:2,components:1};case oc:case ac:return{byteLength:2,components:4};case Yn:case rc:case An:return{byteLength:4,components:1};case Ph:case Ih:return{byteLength:4,components:3}}throw new Error(`THREE.TextureUtils: Unknown texture type ${s}.`)}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:"187"}}));typeof window<"u"&&(window.__THREE__?Tt("WARNING: Multiple instances of Three.js being imported."):window.__THREE__="187");function Sp(){let s=null,t=!1,e=null,n=null;function i(r,o){n=s.requestAnimationFrame(i),e(r,o)}return{start:function(){t!==!0&&e!==null&&s!==null&&(n=s.requestAnimationFrame(i),t=!0)},stop:function(){s!==null&&s.cancelAnimationFrame(n),t=!1},setAnimationLoop:function(r){e=r},setContext:function(r){s=r}}}function Xg(s){let t=new WeakMap;function e(a,c){let l=a.array,h=a.usage,f=l.byteLength,u=s.createBuffer();s.bindBuffer(c,u),s.bufferData(c,l,h),a.onUploadCallback();let d;if(l instanceof Float32Array)d=s.FLOAT;else if(typeof Float16Array<"u"&&l instanceof Float16Array)d=s.HALF_FLOAT;else if(l instanceof Uint16Array)a.isFloat16BufferAttribute?d=s.HALF_FLOAT:d=s.UNSIGNED_SHORT;else if(l instanceof Int16Array)d=s.SHORT;else if(l instanceof Uint32Array)d=s.UNSIGNED_INT;else if(l instanceof Int32Array)d=s.INT;else if(l instanceof Int8Array)d=s.BYTE;else if(l instanceof Uint8Array)d=s.UNSIGNED_BYTE;else if(l instanceof Uint8ClampedArray)d=s.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+l);return{buffer:u,type:d,bytesPerElement:l.BYTES_PER_ELEMENT,version:a.version,size:f}}function n(a,c,l){let h=c.array,f=c.updateRanges;if(s.bindBuffer(l,a),f.length===0)s.bufferSubData(l,0,h);else{f.sort((d,g)=>d.start-g.start);let u=0;for(let d=1;d<f.length;d++){let g=f[u],v=f[d];v.start<=g.start+g.count+1?g.count=Math.max(g.count,v.start+v.count-g.start):(++u,f[u]=v)}f.length=u+1;for(let d=0,g=f.length;d<g;d++){let v=f[d];s.bufferSubData(l,v.start*h.BYTES_PER_ELEMENT,h,v.start,v.count)}c.clearUpdateRanges()}c.onUploadCallback()}function i(a){return a.isInterleavedBufferAttribute&&(a=a.data),t.get(a)}function r(a){a.isInterleavedBufferAttribute&&(a=a.data);let c=t.get(a);c&&(s.deleteBuffer(c.buffer),t.delete(a))}function o(a,c){if(a.isInterleavedBufferAttribute&&(a=a.data),a.isGLBufferAttribute){let h=t.get(a);(!h||h.version<a.version)&&t.set(a,{buffer:a.buffer,type:a.type,bytesPerElement:a.elementSize,version:a.version});return}let l=t.get(a);if(l===void 0)t.set(a,e(a,c));else if(l.version<a.version){if(l.size!==a.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");n(l.buffer,a,c),l.version=a.version}}return{get:i,remove:r,update:o}}var qg=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,Yg=`#ifdef USE_ALPHAHASH
	const float ALPHA_HASH_SCALE = 0.05;
	float hash2D( vec2 value ) {
		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
	}
	float hash3D( vec3 value ) {
		return hash2D( vec2( hash2D( value.xy ), value.z ) );
	}
	float getAlphaHashThreshold( vec3 position ) {
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);
		float lerpFactor = fract( log2( pixScale ) );
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;
		return clamp( threshold , 1.0e-6, 1.0 );
	}
#endif`,Kg=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,Zg=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,Jg=`#ifdef USE_ALPHATEST
	#ifdef ALPHA_TO_COVERAGE
	diffuseColor.a = smoothstep( alphaTest, alphaTest + fwidth( diffuseColor.a ), diffuseColor.a );
	if ( diffuseColor.a == 0.0 ) discard;
	#else
	if ( diffuseColor.a < alphaTest ) discard;
	#endif
#endif`,$g=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,jg=`#ifdef USE_AOMAP
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
	reflectedLight.indirectDiffuse *= ambientOcclusion;
	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD )
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
	#endif
#endif`,Qg=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,t0=`#ifdef USE_BATCHING
	#if ! defined( GL_ANGLE_multi_draw )
	#define gl_DrawID _gl_DrawID
	uniform int _gl_DrawID;
	#endif
	uniform highp sampler2D batchingTexture;
	uniform highp usampler2D batchingIdTexture;
	mat4 getBatchingMatrix( const in float i ) {
		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
	float getIndirectIndex( const in int i ) {
		int size = textureSize( batchingIdTexture, 0 ).x;
		int x = i % size;
		int y = i / size;
		return float( texelFetch( batchingIdTexture, ivec2( x, y ), 0 ).r );
	}
#endif
#ifdef USE_BATCHING_COLOR
	uniform sampler2D batchingColorTexture;
	vec4 getBatchingColor( const in float i ) {
		int size = textureSize( batchingColorTexture, 0 ).x;
		int j = int( i );
		int x = j % size;
		int y = j / size;
		return texelFetch( batchingColorTexture, ivec2( x, y ), 0 );
	}
#endif`,e0=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( getIndirectIndex( gl_DrawID ) );
#endif`,n0=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,i0=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,s0=`float G_BlinnPhong_Implicit( ) {
	return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( specularColor, 1.0, dotVH );
	float G = G_BlinnPhong_Implicit( );
	float D = D_BlinnPhong( shininess, dotNH );
	return F * ( G * D );
} // validated`,r0=`#ifdef USE_IRIDESCENCE
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {
		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );
	}
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - vec3( incidentIor ) ) / ( transmittedIor + vec3( incidentIor ) ) );
	}
	float IorToFresnel0( float transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));
	}
	vec3 evalSensitivity( float OPD, vec3 shift ) {
		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );
		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;
		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;
	}
	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {
		vec3 I;
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {
			return vec3( 1.0 );
		}
		float cosTheta2 = sqrt( cosTheta2Sq );
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) );		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3( 0.0 );
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21 ) + phi23;
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );
		vec3 C0 = R12 + Rs;
		I = C0;
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {
			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;
		}
		return max( I, vec3( 0.0 ) );
	}
#endif`,o0=`#ifdef USE_BUMPMAP
	uniform sampler2D bumpMap;
	uniform float bumpScale;
	vec2 dHdxy_fwd() {
		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );
		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
		return vec2( dBx, dBy );
	}
	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm;
		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );
		float fDet = dot( vSigmaX, R1 ) * faceDirection;
		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );
	}
#endif`,a0=`#if NUM_CLIPPING_PLANES > 0
	vec4 plane;
	#ifdef ALPHA_TO_COVERAGE
		float distanceToPlane, distanceGradient;
		float clipOpacity = 1.0;
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
			distanceGradient = fwidth( distanceToPlane ) / 2.0;
			clipOpacity *= smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			if ( clipOpacity == 0.0 ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			float unionClipOpacity = 1.0;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				distanceToPlane = - dot( vClipPosition, plane.xyz ) + plane.w;
				distanceGradient = fwidth( distanceToPlane ) / 2.0;
				unionClipOpacity *= 1.0 - smoothstep( - distanceGradient, distanceGradient, distanceToPlane );
			}
			#pragma unroll_loop_end
			clipOpacity *= 1.0 - unionClipOpacity;
		#endif
		diffuseColor.a *= clipOpacity;
		if ( diffuseColor.a == 0.0 ) discard;
	#else
		#pragma unroll_loop_start
		for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;
		}
		#pragma unroll_loop_end
		#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
			bool clipped = true;
			#pragma unroll_loop_start
			for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
				plane = clippingPlanes[ i ];
				clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;
			}
			#pragma unroll_loop_end
			if ( clipped ) discard;
		#endif
	#endif
#endif`,c0=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,l0=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,h0=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,u0=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#endif`,f0=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#endif`,d0=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	varying vec4 vColor;
#endif`,p0=`#if defined( USE_COLOR ) || defined( USE_COLOR_ALPHA ) || defined( USE_INSTANCING_COLOR ) || defined( USE_BATCHING_COLOR )
	vColor = vec4( 1.0 );
#endif
#ifdef USE_COLOR_ALPHA
	vColor *= color;
#elif defined( USE_COLOR )
	vColor.rgb *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.rgb *= instanceColor.rgb;
#endif
#ifdef USE_BATCHING_COLOR
	vColor *= getBatchingColor( getIndirectIndex( gl_DrawID ) );
#endif`,m0=`#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif
struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};
struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
	varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
#define inverseTransformDirection transformDirectionByInverseViewMatrix
vec3 transformNormalByInverseViewMatrix( in vec3 normal, in mat4 viewMatrix ) {
	return normalize( ( vec4( normal, 0.0 ) * viewMatrix ).xyz );
}
vec3 transformDirectionByInverseViewMatrix( in vec3 dir, in mat4 viewMatrix ) {
	return normalize( ( vec4( dir, 0.0 ) * viewMatrix ).xyz );
}
bool isPerspectiveMatrix( mat4 m ) {
	return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
	float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
	return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
	return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated`,g0=`vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
	vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = bm * transformedTangent;
	#endif
#endif
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = im * transformedTangent;
	#endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
	transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
#endif`,_0=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,x0=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,y0=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	#ifdef DECODE_VIDEO_TEXTURE_EMISSIVE
		emissiveColor = sRGBTransferEOTF( emissiveColor );
	#endif
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,v0=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,M0="gl_FragColor = linearToOutputTexel( gl_FragColor );",S0=`vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}
vec4 sRGBTransferEOTF( in vec4 value ) {
	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 sRGBTransferOETF( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}`,b0=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vec3 cameraToFrag;
		if ( isOrthographic ) {
			cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToFrag = normalize( vWorldPosition - cameraPosition );
		}
		vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vec3 reflectVec = reflect( cameraToFrag, worldNormal );
		#else
			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
		#endif
	#else
		vec3 reflectVec = vReflect;
	#endif
	#ifdef ENVMAP_TYPE_CUBE
		vec4 envColor = textureCube( envMap, envMapRotation * reflectVec );
		#ifdef ENVMAP_BLENDING_MULTIPLY
			outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
		#elif defined( ENVMAP_BLENDING_MIX )
			outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
		#elif defined( ENVMAP_BLENDING_ADD )
			outgoingLight += envColor.xyz * specularStrength * reflectivity;
		#endif
	#endif
#endif`,T0=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform mat3 envMapRotation;
	uniform samplerCube envMap;
	#ifdef ENVMAP_TYPE_PMREM
		float roughnessToMip( const in float roughness ) {
			float r = clamp( roughness, 0.0, 1.0 );
			return ENVMAP_MAX_LOD * r * ( 2.0 - r );
		}
	#endif
#endif`,w0=`#ifdef USE_ENVMAP
	uniform float reflectivity;
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		varying vec3 vWorldPosition;
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif
#endif`,A0=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,E0=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vWorldPosition = worldPosition.xyz;
	#else
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 worldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vReflect = reflect( cameraToVertex, worldNormal );
		#else
			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );
		#endif
	#endif
#endif`,R0=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,C0=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,P0=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,I0=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,L0=`#ifdef USE_GRADIENTMAP
	uniform sampler2D gradientMap;
#endif
vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );
	#ifdef USE_GRADIENTMAP
		return vec3( texture2D( gradientMap, coord ).r );
	#else
		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );
	#endif
}`,N0=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,D0=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,U0=`varying vec3 vViewPosition;
struct LambertMaterial {
	vec3 diffuseColor;
	float specularStrength;
};
void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,F0=`uniform bool receiveShadow;
uniform vec3 ambientLightColor;
#if defined( USE_LIGHT_PROBES )
	uniform vec3 lightProbe[ 9 ];
#endif
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {
	float x = normal.x, y = normal.y, z = normal.z;
	vec3 result = shCoefficients[ 0 ] * 0.886227;
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
	return result;
}
vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {
	vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );
	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
	return irradiance;
}
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
	vec3 irradiance = ambientLightColor;
	return irradiance;
}
float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
	float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
	if ( cutoffDistance > 0.0 ) {
		distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
	}
	return distanceFalloff;
}
float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {
	return smoothstep( coneCosine, penumbraCosine, angleCosine );
}
#if NUM_SUN_LIGHTS > 0
	struct SunLight {
		vec3 direction;
		vec3 color;
	};
	uniform SunLight sunLights[ NUM_SUN_LIGHTS ];
	void getSunLightInfo( const in SunLight sunLight, out IncidentLight light ) {
		light.color = sunLight.color;
		light.direction = sunLight.direction;
		light.visible = true;
	}
#endif
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
	void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {
		light.color = directionalLight.color;
		light.direction = directionalLight.direction;
		light.visible = true;
	}
#endif
#if NUM_POINT_LIGHTS > 0
	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;
	};
	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
	void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = pointLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float lightDistance = length( lVector );
		light.color = pointLight.color;
		light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
		light.visible = ( light.color != vec3( 0.0 ) );
	}
#endif
#if NUM_SPOT_LIGHTS > 0
	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;
	};
	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
	void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = spotLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float angleCos = dot( light.direction, spotLight.direction );
		float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );
		if ( spotAttenuation > 0.0 ) {
			float lightDistance = length( lVector );
			light.color = spotLight.color * spotAttenuation;
			light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
			light.visible = ( light.color != vec3( 0.0 ) );
		} else {
			light.color = vec3( 0.0 );
			light.visible = false;
		}
	}
#endif
#if NUM_RECT_AREA_LIGHTS > 0
	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};
	uniform sampler2D ltc_1;	uniform sampler2D ltc_2;
	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
#endif
#if NUM_HEMI_LIGHTS > 0
	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};
	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {
		float dotNL = dot( normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
		return irradiance;
	}
#endif
#include <lightprobes_pars_fragment>`,O0=`#ifdef USE_ENVMAP
	vec3 getIBLIrradiance( const in vec3 normal ) {
		#ifdef ENVMAP_TYPE_PMREM
			vec3 worldNormal = transformNormalByInverseViewMatrix( normal, viewMatrix );
			vec4 envMapColor = textureLod( envMap, envMapRotation * worldNormal, ENVMAP_MAX_LOD );
			return PI * envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
		#ifdef ENVMAP_TYPE_PMREM
			vec3 reflectVec = reflect( - viewDir, normal );
			reflectVec = normalize( mix( reflectVec, normal, pow4( roughness ) ) );
			reflectVec = transformDirectionByInverseViewMatrix( reflectVec, viewMatrix );
			vec4 envMapColor = textureLod( envMap, envMapRotation * reflectVec, roughnessToMip( roughness ) );
			return envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	#ifdef USE_RETROREFLECTION
		vec3 getIBLRetroRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
			#ifdef ENVMAP_TYPE_PMREM
				vec3 retroVec = normalize( mix( viewDir, normal, pow4( roughness ) ) );
				retroVec = transformDirectionByInverseViewMatrix( retroVec, viewMatrix );
				vec4 envMapColor = textureLod( envMap, envMapRotation * retroVec, roughnessToMip( roughness ) );
				return envMapColor.rgb * envMapIntensity;
			#else
				return vec3( 0.0 );
			#endif
		}
	#endif
	#ifdef USE_ANISOTROPY
		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
			#ifdef ENVMAP_TYPE_PMREM
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
				return getIBLRadiance( viewDir, bentNormal, roughness );
			#else
				return vec3( 0.0 );
			#endif
		}
		#ifdef USE_RETROREFLECTION
			vec3 getIBLAnisotropyRetroRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
				#ifdef ENVMAP_TYPE_PMREM
					vec3 bentNormal = cross( bitangent, viewDir );
					bentNormal = normalize( cross( bentNormal, bitangent ) );
					bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
					return getIBLRetroRadiance( viewDir, bentNormal, roughness );
				#else
					return vec3( 0.0 );
				#endif
			}
		#endif
	#endif
#endif`,B0=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,z0=`varying vec3 vViewPosition;
struct ToonMaterial {
	vec3 diffuseColor;
};
void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,k0=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,V0=`varying vec3 vViewPosition;
struct BlinnPhongMaterial {
	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;
};
void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;
}
void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,G0=`PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.diffuseContribution = diffuseColor.rgb * ( 1.0 - metalnessFactor );
material.metalness = metalnessFactor;
vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
material.roughness = max( roughnessFactor, 0.045 );
material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );
#ifdef USE_DIFFUSE_ROUGHNESS
	float diffuseRoughnessFactor = diffuseRoughness;
	#ifdef USE_DIFFUSE_ROUGHNESSMAP
		diffuseRoughnessFactor *= texture2D( diffuseRoughnessMap, vDiffuseRoughnessMapUv ).r;
	#endif
	material.diffuseRoughness = saturate( diffuseRoughnessFactor );
#endif
#ifdef IOR
	material.ior = ior;
	#ifdef USE_SPECULAR
		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;
		#ifdef USE_SPECULAR_COLORMAP
			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;
		#endif
		#ifdef USE_SPECULAR_INTENSITYMAP
			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;
		#endif
		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );
	#else
		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3( 1.0 );
		material.specularF90 = 1.0;
	#endif
	material.specularColor = min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3( 1.0 ) ) * specularIntensityFactor;
	material.specularColorBlended = mix( material.specularColor, diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = vec3( 0.04 );
	material.specularColorBlended = mix( material.specularColor, diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;
#endif
#ifdef USE_CLEARCOAT
	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3( 0.04 );
	material.clearcoatF90 = 1.0;
	#ifdef USE_CLEARCOATMAP
		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;
	#endif
	#ifdef USE_CLEARCOAT_ROUGHNESSMAP
		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;
	#endif
	material.clearcoat = saturate( material.clearcoat );	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.045 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );
#endif
#ifdef USE_DISPERSION
	material.dispersion = dispersion;
#endif
#ifdef USE_RETROREFLECTION
	material.retroreflectivity = retroreflectivity;
#endif
#ifdef USE_IRIDESCENCE
	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;
	#ifdef USE_IRIDESCENCEMAP
		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;
	#endif
	#ifdef USE_IRIDESCENCE_THICKNESSMAP
		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;
	#else
		material.iridescenceThickness = iridescenceThicknessMaximum;
	#endif
#endif
#ifdef USE_SHEEN
	material.sheenColor = sheenColor;
	#ifdef USE_SHEEN_COLORMAP
		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;
	#endif
	material.sheenRoughness = clamp( sheenRoughness, 0.0001, 1.0 );
	#ifdef USE_SHEEN_ROUGHNESSMAP
		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;
	#endif
#endif
#ifdef USE_ANISOTROPY
	#ifdef USE_ANISOTROPYMAP
		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;
	#else
		vec2 anisotropyV = anisotropyVector;
	#endif
	material.anisotropy = length( anisotropyV );
	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );
	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;
#endif`,H0=`uniform sampler2D dfgLUT;
struct PhysicalMaterial {
	vec3 diffuseColor;
	vec3 diffuseContribution;
	vec3 specularColor;
	vec3 specularColorBlended;
	float roughness;
	float metalness;
	float specularF90;
	float dispersion;
	vec2 dfg;
	vec3 multiScatteringCompensation;
	#ifdef USE_DIFFUSE_ROUGHNESS
		float diffuseRoughness;
	#endif
	#ifdef USE_RETROREFLECTION
		float retroreflectivity;
	#endif
	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif
	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0Dielectric;
		vec3 iridescenceF0Metallic;
	#endif
	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif
	#ifdef IOR
		float ior;
	#endif
	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif
	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif
};
vec3 clearcoatSpecularDirect = vec3( 0.0 );
vec3 clearcoatSpecularIndirect = vec3( 0.0 );
vec3 sheenSpecularDirect = vec3( 0.0 );
vec3 sheenSpecularIndirect = vec3(0.0 );
vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );
    return ( f - vec3( f90 ) * x5 ) / ( 1.0 - x5 );
}
#ifdef USE_DIFFUSE_ROUGHNESS
	const float EON_EPSILON = 1e-7;
	float FON_DirectionalAlbedo( const in float mu, const in float roughness, const in float A ) {
		float muComp = 1.0 - mu;
		float gOverPi = muComp * ( 0.0571085289 + muComp * ( 0.491881867 + muComp * ( - 0.332181442 + muComp * 0.0714429953 ) ) );
		return A * ( 1.0 + roughness * gOverPi );
	}
	vec3 BRDF_EON( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 diffuseColor, const in float roughness ) {
		vec3 rho = saturate( diffuseColor );
		if ( roughness <= EON_EPSILON ) return BRDF_Lambert( rho );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float s = dot( lightDir, viewDir ) - dotNL * dotNV;
		float sOverT = ( s > 0.0 ) ? s / max( max( dotNL, dotNV ), EON_EPSILON ) : s;
		float A = 1.0 / ( 1.0 + ( 0.5 - 2.0 / ( 3.0 * PI ) ) * roughness );
		vec3 singleScatter = rho * RECIPROCAL_PI * A * ( 1.0 + roughness * sOverT );
		float averageAlbedo = A * ( 1.0 + ( 2.0 / 3.0 - 28.0 / ( 15.0 * PI ) ) * roughness );
		float albedoV = FON_DirectionalAlbedo( dotNV, roughness, A );
		float albedoL = FON_DirectionalAlbedo( dotNL, roughness, A );
		vec3 rhoMultiScatter = rho * rho * averageAlbedo / max( vec3( EON_EPSILON ), vec3( 1.0 ) - rho * ( 1.0 - averageAlbedo ) );
		vec3 multiScatter = rhoMultiScatter * RECIPROCAL_PI
			* max( EON_EPSILON, 1.0 - albedoV )
			* max( EON_EPSILON, 1.0 - albedoL )
			/ max( EON_EPSILON, 1.0 - averageAlbedo );
		return singleScatter + multiScatter;
	}
	vec3 EON_DirectionalAlbedo( const in vec3 diffuseColor, const in float roughness, const in float dotNV ) {
		vec3 rho = saturate( diffuseColor );
		if ( roughness <= EON_EPSILON ) return rho;
		float A = 1.0 / ( 1.0 + ( 0.5 - 2.0 / ( 3.0 * PI ) ) * roughness );
		float directionalAlbedo = FON_DirectionalAlbedo( dotNV, roughness, A );
		float averageAlbedo = A * ( 1.0 + ( 2.0 / 3.0 - 28.0 / ( 15.0 * PI ) ) * roughness );
		vec3 rhoMultiScatter = rho * rho * averageAlbedo / max( vec3( EON_EPSILON ), vec3( 1.0 ) - rho * ( 1.0 - averageAlbedo ) );
		return rho * directionalAlbedo + rhoMultiScatter * ( 1.0 - directionalAlbedo );
	}
#endif
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
	float a2 = pow2( alpha );
	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
	return RECIPROCAL_PI * a2 / pow2( denom );
}
#ifdef USE_ANISOTROPY
	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {
		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		return 0.5 / max( gv + gl, EPSILON );
	}
	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {
		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;
		return RECIPROCAL_PI * a2 * pow2 ( w2 );
	}
#endif
#ifdef USE_CLEARCOAT
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {
		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = max( material.clearcoatRoughness, 0.045 );
		float alpha = pow2( roughness );
		vec3 halfDir = normalize( lightDir + viewDir );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );
		vec3 F = F_Schlick( f0, f90, dotVH );
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
		return F * ( V * D );
	}
#endif
vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {
	vec3 f0 = material.specularColorBlended;
	float f90 = material.specularF90;
	float roughness = max( material.roughness, 0.045 );
	float alpha = pow2( roughness );
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( f0, f90, dotVH );
	#ifdef USE_IRIDESCENCE
		F = mix( F, material.iridescenceFresnel, material.iridescence );
	#endif
	#ifdef USE_ANISOTROPY
		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );
		float alphaT = max( material.alphaT, alpha );
		float V = V_GGX_SmithCorrelated_Anisotropic( alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );
		float D = D_GGX_Anisotropic( alphaT, alpha, dotNH, dotTH, dotBH );
	#else
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
	#endif
	return F * ( V * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;
	float dotNV = saturate( dot( N, V ) );
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 );
	mat3 mat = mInv * transpose( mat3( T1, T2, N ) );
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
	return vec3( result );
}
#if defined( USE_SHEEN )
float D_Charlie( float roughness, float dotNH ) {
	float alpha = pow2( roughness );
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 );
	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );
}
float V_Neubelt( float dotNV, float dotNL ) {
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );
}
vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );
	return sheenColor * ( D * V );
}
#endif
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	float r2 = roughness * roughness;
	float rInv = 1.0 / ( roughness + 0.1 );
	float a = -1.9362 + 1.0678 * roughness + 0.4573 * r2 - 0.8469 * rInv;
	float b = -0.6014 + 0.5538 * roughness - 0.4670 * r2 - 0.1255 * rInv;
	float DG = exp( a * dotNV + b );
	return saturate( DG );
}
vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	vec2 fab = texture2D( dfgLUT, vec2( roughness, dotNV ) ).rg;
	return specularColor * fab.x + specularF90 * fab.y;
}
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec2 fab, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec2 fab, const in vec3 specularColor, const in float specularF90, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif
	#ifdef USE_IRIDESCENCE
		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );
	#else
		vec3 Fr = specularColor;
	#endif
	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;
	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;
	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619;	vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
	singleScatter += FssEss;
	multiScatter += Fms * Ems;
}
#if NUM_RECT_AREA_LIGHTS > 0
	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;
		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight;		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;
		vec2 uv = LTC_Uv( normal, viewDir, roughness );
		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );
		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);
		vec3 fresnel = ( material.specularColorBlended * t2.x + ( material.specularF90 - material.specularColorBlended ) * t2.y );
		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );
		reflectedLight.directDiffuse += lightColor * material.diffuseContribution * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );
		#ifdef USE_CLEARCOAT
			vec3 Ncc = geometryClearcoatNormal;
			vec2 uvClearcoat = LTC_Uv( Ncc, viewDir, material.clearcoatRoughness );
			vec4 t1Clearcoat = texture2D( ltc_1, uvClearcoat );
			vec4 t2Clearcoat = texture2D( ltc_2, uvClearcoat );
			mat3 mInvClearcoat = mat3(
				vec3( t1Clearcoat.x, 0, t1Clearcoat.y ),
				vec3(             0, 1,             0 ),
				vec3( t1Clearcoat.z, 0, t1Clearcoat.w )
			);
			vec3 fresnelClearcoat = material.clearcoatF0 * t2Clearcoat.x + ( material.clearcoatF90 - material.clearcoatF0 ) * t2Clearcoat.y;
			clearcoatSpecularDirect += lightColor * fresnelClearcoat * LTC_Evaluate( Ncc, viewDir, position, mInvClearcoat, rectCoords );
		#endif
	}
#endif
void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	#ifdef USE_CLEARCOAT
		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );
		vec3 ccIrradiance = dotNLcc * directLight.color;
		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );
	#endif
	#ifdef USE_SHEEN
 
 		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
 
 		float sheenAlbedoV = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
 		float sheenAlbedoL = IBLSheenBRDF( geometryNormal, directLight.direction, material.sheenRoughness );
 
 		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * max( sheenAlbedoV, sheenAlbedoL );
 
 		irradiance *= sheenEnergyComp;
 
 	#endif
	vec3 specularBRDF = BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );
	#ifdef USE_RETROREFLECTION
		vec3 retroViewDir = reflect( - geometryViewDir, geometryNormal );
		vec3 retroSpecularBRDF = BRDF_GGX( directLight.direction, retroViewDir, geometryNormal, material );
		specularBRDF = mix( specularBRDF, retroSpecularBRDF, saturate( material.retroreflectivity ) );
	#endif
	reflectedLight.directSpecular += irradiance * specularBRDF * material.multiScatteringCompensation;
	vec3 halfDir = normalize( directLight.direction + geometryViewDir );
	float dotVH = saturate( dot( geometryViewDir, halfDir ) );
	vec3 F = F_Schlick( material.specularColor, material.specularF90, dotVH );
	#ifdef USE_RETROREFLECTION
		vec3 retroHalfDir = normalize( directLight.direction + retroViewDir );
		float dotRetroVH = saturate( dot( retroViewDir, retroHalfDir ) );
		vec3 retroF = F_Schlick( material.specularColor, material.specularF90, dotRetroVH );
		F = mix( F, retroF, saturate( material.retroreflectivity ) );
	#endif
	#ifdef USE_DIFFUSE_ROUGHNESS
		vec3 diffuseBRDF = BRDF_EON( directLight.direction, geometryViewDir, geometryNormal, material.diffuseColor, material.diffuseRoughness ) * ( 1.0 - material.metalness );
	#else
		vec3 diffuseBRDF = BRDF_Lambert( material.diffuseContribution );
	#endif
	reflectedLight.directDiffuse += irradiance * diffuseBRDF * ( 1.0 - F );
}
void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 singleScattering = vec3( 0.0 );
	vec3 multiScattering = vec3( 0.0 );
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( material.dfg, material.specularColor, material.specularF90, material.iridescence, material.iridescenceF0Dielectric, singleScattering, multiScattering );
	#else
		computeMultiscattering( material.dfg, material.specularColor, material.specularF90, singleScattering, multiScattering );
	#endif
	#ifdef USE_DIFFUSE_ROUGHNESS
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		vec3 diffuseAlbedo = EON_DirectionalAlbedo( material.diffuseColor, material.diffuseRoughness, dotNV ) * ( 1.0 - material.metalness );
		vec3 diffuse = irradiance * RECIPROCAL_PI * diffuseAlbedo * ( 1.0 - singleScattering - multiScattering );
	#else
		vec3 diffuse = irradiance * BRDF_Lambert( material.diffuseContribution ) * ( 1.0 - singleScattering - multiScattering );
	#endif
	#ifdef USE_SHEEN
		float sheenAlbedo = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
		sheenSpecularIndirect += irradiance * material.sheenColor * sheenAlbedo * RECIPROCAL_PI;
		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * sheenAlbedo;
		diffuse *= sheenEnergyComp;
	#endif
	reflectedLight.indirectDiffuse += diffuse;
}
void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
	#ifdef USE_CLEARCOAT
		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness ) * RECIPROCAL_PI;
 	#endif
	vec3 singleScatteringDielectric = vec3( 0.0 );
	vec3 multiScatteringDielectric = vec3( 0.0 );
	vec3 singleScatteringMetallic = vec3( 0.0 );
	vec3 multiScatteringMetallic = vec3( 0.0 );
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( material.dfg, material.specularColor, material.specularF90, material.iridescence, material.iridescenceF0Dielectric, singleScatteringDielectric, multiScatteringDielectric );
		computeMultiscatteringIridescence( material.dfg, material.diffuseColor, material.specularF90, material.iridescence, material.iridescenceF0Metallic, singleScatteringMetallic, multiScatteringMetallic );
	#else
		computeMultiscattering( material.dfg, material.specularColor, material.specularF90, singleScatteringDielectric, multiScatteringDielectric );
		computeMultiscattering( material.dfg, material.diffuseColor, material.specularF90, singleScatteringMetallic, multiScatteringMetallic );
	#endif
	vec3 singleScattering = mix( singleScatteringDielectric, singleScatteringMetallic, material.metalness );
	vec3 multiScattering = mix( multiScatteringDielectric, multiScatteringMetallic, material.metalness );
	vec3 totalScatteringDielectric = singleScatteringDielectric + multiScatteringDielectric;
	#ifdef USE_DIFFUSE_ROUGHNESS
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		vec3 diffuse = EON_DirectionalAlbedo( material.diffuseColor, material.diffuseRoughness, dotNV ) * ( 1.0 - material.metalness ) * ( 1.0 - totalScatteringDielectric );
	#else
		vec3 diffuse = material.diffuseContribution * ( 1.0 - totalScatteringDielectric );
	#endif
	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;
	vec3 indirectSpecular = radiance * singleScattering;
	indirectSpecular += multiScattering * cosineWeightedIrradiance;
	vec3 indirectDiffuse = diffuse * cosineWeightedIrradiance;
	#ifdef USE_SHEEN
		float sheenAlbedo = IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
		float sheenEnergyComp = 1.0 - max3( material.sheenColor ) * sheenAlbedo;
		indirectSpecular *= sheenEnergyComp;
		indirectDiffuse *= sheenEnergyComp;
	#endif
	reflectedLight.indirectSpecular += indirectSpecular;
	reflectedLight.indirectDiffuse += indirectDiffuse;
}
#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {
	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}`,W0=`
vec3 geometryPosition = - vViewPosition;
vec3 geometryNormal = normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( vViewPosition );
vec3 geometryClearcoatNormal = vec3( 0.0 );
#ifdef USE_CLEARCOAT
	geometryClearcoatNormal = clearcoatNormal;
#endif
#ifdef USE_IRIDESCENCE
	float dotNVi = saturate( dot( normal, geometryViewDir ) );
	if ( material.iridescenceThickness == 0.0 ) {
		material.iridescence = 0.0;
	} else {
		material.iridescence = saturate( material.iridescence );
	}
	if ( material.iridescence > 0.0 ) {
		vec3 iridescenceFresnelDielectric = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		vec3 iridescenceFresnelMetallic = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.diffuseColor );
		material.iridescenceFresnel = mix( iridescenceFresnelDielectric, iridescenceFresnelMetallic, material.metalness );
		material.iridescenceF0Dielectric = Schlick_to_F0( iridescenceFresnelDielectric, 1.0, dotNVi );
		material.iridescenceF0Metallic = Schlick_to_F0( iridescenceFresnelMetallic, 1.0, dotNVi );
	}
#endif
#ifdef STANDARD
	float dotNVms = saturate( dot( geometryNormal, geometryViewDir ) );
	material.dfg = texture2D( dfgLUT, vec2( material.roughness, dotNVms ) ).rg;
	#if ( NUM_SUN_LIGHTS > 0 || NUM_DIR_LIGHTS > 0 || NUM_POINT_LIGHTS > 0 || NUM_SPOT_LIGHTS > 0 )
		float EssMs = material.dfg.x + material.dfg.y;
		material.multiScatteringCompensation = 1.0 + material.specularColorBlended * ( 1.0 / EssMs - 1.0 );
	#endif
#endif
IncidentLight directLight;
#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )
	PointLight pointLight;
	#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		pointLight = pointLights[ i ];
		getPointLightInfo( pointLight, geometryPosition, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_POINT_LIGHT_SHADOWS ) && ( defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_BASIC ) )
		pointLightShadow = pointLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getPointShadow( pointShadowMap[ i ], pointLightShadow.shadowMapSize, pointLightShadow.shadowIntensity, pointLightShadow.shadowBias, pointLightShadow.shadowRadius, vPointShadowCoord[ i ], pointLightShadow.shadowCameraNear, pointLightShadow.shadowCameraFar ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )
	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;
	#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		spotLight = spotLights[ i ];
		getSpotLightInfo( spotLight, geometryPosition, directLight );
		#if ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#define SPOT_LIGHT_MAP_INDEX UNROLLED_LOOP_INDEX
		#elif ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		#define SPOT_LIGHT_MAP_INDEX NUM_SPOT_LIGHT_MAPS
		#else
		#define SPOT_LIGHT_MAP_INDEX ( UNROLLED_LOOP_INDEX - NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#endif
		#if ( SPOT_LIGHT_MAP_INDEX < NUM_SPOT_LIGHT_MAPS )
			spotLightCoord = vSpotLightCoord[ i ].xyz / vSpotLightCoord[ i ].w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3( 1.0 ) ) );
			spotColor = texture2D( spotLightMap[ SPOT_LIGHT_MAP_INDEX ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		#endif
		#undef SPOT_LIGHT_MAP_INDEX
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		spotLightShadow = spotLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( spotShadowMap[ i ], spotLightShadow.shadowMapSize, spotLightShadow.shadowIntensity, spotLightShadow.shadowBias, spotLightShadow.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SUN_LIGHTS > 0 ) && defined( RE_Direct )
	SunLight sunLight;
	#if defined( USE_SHADOWMAP ) && NUM_SUN_LIGHT_SHADOWS > 0
	SunLightShadow sunLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SUN_LIGHTS; i ++ ) {
		sunLight = sunLights[ i ];
		getSunLightInfo( sunLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SUN_LIGHT_SHADOWS )
		sunLightShadow = sunLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getSunShadow( sunShadowMap[ i ], sunLightShadow, UNROLLED_LOOP_INDEX ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )
	DirectionalLight directionalLight;
	#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		directionalLight = directionalLights[ i ];
		getDirectionalLightInfo( directionalLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_DIR_LIGHT_SHADOWS )
		directionalLightShadow = directionalLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( directionalShadowMap[ i ], directionalLightShadow.shadowMapSize, directionalLightShadow.shadowIntensity, directionalLightShadow.shadowBias, directionalLightShadow.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )
	RectAreaLight rectAreaLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {
		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if defined( RE_IndirectDiffuse )
	vec3 iblIrradiance = vec3( 0.0 );
	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );
	#if defined( USE_LIGHT_PROBES )
		irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );
	#endif
	#if ( NUM_HEMI_LIGHTS > 0 )
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {
			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometryNormal );
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_LIGHT_PROBE_GRIDS > 0
		vec3 probeWorldPos = ( ( vec4( geometryPosition, 1.0 ) - viewMatrix[ 3 ] ) * viewMatrix ).xyz;
		vec3 probeWorldNormal = transformNormalByInverseViewMatrix( geometryNormal, viewMatrix );
		int probeGrid = - 1;
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_LIGHT_PROBE_GRIDS; i ++ ) {
			if ( isInsideLightProbeGrid( probeWorldPos, probeWorldNormal, probesMin[ i ], probesMax[ i ], probesResolution[ i ] ) ) probeGrid = UNROLLED_LOOP_INDEX;
		}
		#pragma unroll_loop_end
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_LIGHT_PROBE_GRIDS; i ++ ) {
			if ( probeGrid == UNROLLED_LOOP_INDEX ) irradiance += getLightProbeGridIrradiance( probesSH[ i ], probesMin[ i ], probesMax[ i ], probesResolution[ i ], probeWorldPos, probeWorldNormal );
		}
		#pragma unroll_loop_end
	#endif
#endif
#if defined( RE_IndirectSpecular )
	vec3 radiance = vec3( 0.0 );
	vec3 clearcoatRadiance = vec3( 0.0 );
#endif`,X0=`#if defined( RE_IndirectDiffuse )
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
		irradiance += lightMapIrradiance;
	#endif
	#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_PMREM )
		#if defined( STANDARD ) || defined( LAMBERT ) || defined( PHONG )
			iblIrradiance += getIBLIrradiance( geometryNormal );
		#endif
	#endif
#endif
#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )
	#ifdef USE_ANISOTROPY
		vec3 iblRadiance = getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
	#else
		vec3 iblRadiance = getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );
	#endif
	#ifdef USE_RETROREFLECTION
		#ifdef USE_ANISOTROPY
			vec3 retroIBLRadiance = getIBLAnisotropyRetroRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
		#else
			vec3 retroIBLRadiance = getIBLRetroRadiance( geometryViewDir, geometryNormal, material.roughness );
		#endif
		iblRadiance = mix( iblRadiance, retroIBLRadiance, saturate( material.retroreflectivity ) );
	#endif
	radiance += iblRadiance;
	#ifdef USE_CLEARCOAT
		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );
	#endif
#endif`,q0=`#if defined( RE_IndirectDiffuse )
	#if defined( LAMBERT ) || defined( PHONG )
		irradiance += iblIrradiance;
	#endif
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,Y0=`#if NUM_LIGHT_PROBE_GRIDS > 0
uniform highp sampler3D probesSH[ NUM_LIGHT_PROBE_GRIDS ];
uniform vec3 probesMin[ NUM_LIGHT_PROBE_GRIDS ];
uniform vec3 probesMax[ NUM_LIGHT_PROBE_GRIDS ];
uniform vec3 probesResolution[ NUM_LIGHT_PROBE_GRIDS ];
bool isInsideLightProbeGrid( vec3 worldPos, vec3 worldNormal, vec3 probesMin, vec3 probesMax, vec3 probesResolution ) {
	vec3 spacing = ( probesMax - probesMin ) / probesResolution;
	vec3 samplePos = worldPos + worldNormal * spacing * 0.5;
	vec3 margin = spacing * 0.01;
	return all( greaterThanEqual( samplePos, probesMin - margin ) ) && all( lessThanEqual( samplePos, probesMax + margin ) );
}
vec3 getLightProbeGridIrradiance( highp sampler3D probesSH, vec3 probesMin, vec3 probesMax, vec3 probesResolution, vec3 worldPos, vec3 worldNormal ) {
	vec3 res = probesResolution;
	vec3 gridRange = probesMax - probesMin;
	vec3 probeSpacing = gridRange / res;
	vec3 samplePos = worldPos + worldNormal * probeSpacing * 0.5;
	vec3 uvw = clamp( ( samplePos - probesMin ) / gridRange, 0.5 / res, 1.0 - 0.5 / res );
	float nz          = res.z;
	float paddedSlices = nz + 2.0;
	float atlasDepth  = 7.0 * paddedSlices;
	float uvZBase     = uvw.z * nz + 1.0;
	vec4 s0 = texture( probesSH, vec3( uvw.xy, ( uvZBase                       ) / atlasDepth ) );
	vec4 s1 = texture( probesSH, vec3( uvw.xy, ( uvZBase +       paddedSlices   ) / atlasDepth ) );
	vec4 s2 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 2.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s3 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 3.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s4 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 4.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s5 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 5.0 * paddedSlices   ) / atlasDepth ) );
	vec4 s6 = texture( probesSH, vec3( uvw.xy, ( uvZBase + 6.0 * paddedSlices   ) / atlasDepth ) );
	vec3 c0 = s0.xyz;
	vec3 c1 = vec3( s0.w, s1.xy );
	vec3 c2 = vec3( s1.zw, s2.x );
	vec3 c3 = s2.yzw;
	vec3 c4 = s3.xyz;
	vec3 c5 = vec3( s3.w, s4.xy );
	vec3 c6 = vec3( s4.zw, s5.x );
	vec3 c7 = s5.yzw;
	vec3 c8 = s6.xyz;
	float x = worldNormal.x, y = worldNormal.y, z = worldNormal.z;
	vec3 result = c0 * 0.886227;
	result += c1 * 2.0 * 0.511664 * y;
	result += c2 * 2.0 * 0.511664 * z;
	result += c3 * 2.0 * 0.511664 * x;
	result += c4 * 2.0 * 0.429043 * x * y;
	result += c5 * 2.0 * 0.429043 * y * z;
	result += c6 * ( 0.743125 * z * z - 0.247708 );
	result += c7 * 2.0 * 0.429043 * x * z;
	result += c8 * 0.429043 * ( x * x - y * y );
	return max( result, vec3( 0.0 ) );
}
#endif`,K0=`#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
	gl_FragDepth = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,Z0=`#if defined( USE_LOGARITHMIC_DEPTH_BUFFER )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,J0=`#ifdef USE_LOGARITHMIC_DEPTH_BUFFER
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,$0=`#ifdef USE_LOGARITHMIC_DEPTH_BUFFER
	vFragDepth = 1.0 + gl_Position.w;
	vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
#endif`,j0=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = sRGBTransferEOTF( sampledDiffuseColor );
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,Q0=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,t_=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
	#if defined( USE_POINTS_UV )
		vec2 uv = vUv;
	#else
		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	#endif
#endif
#ifdef USE_MAP
	diffuseColor *= texture2D( map, uv );
#endif
#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, uv ).g;
#endif`,e_=`#if defined( USE_POINTS_UV )
	varying vec2 vUv;
#else
	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
		uniform mat3 uvTransform;
	#endif
#endif
#ifdef USE_MAP
	uniform sampler2D map;
#endif
#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,n_=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,i_=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,s_=`#ifdef USE_INSTANCING_MORPH
	float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	float morphTargetBaseInfluence = texelFetch( morphTexture, ivec2( 0, gl_InstanceID ), 0 ).r;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		morphTargetInfluences[i] =  texelFetch( morphTexture, ivec2( i + 1, gl_InstanceID ), 0 ).r;
	}
#endif`,r_=`#if defined( USE_MORPHCOLORS )
	#if defined( USE_COLOR_ALPHA )
		vColor *= morphTargetBaseInfluence;
	#elif defined( USE_COLOR )
		vColor.rgb *= morphTargetBaseInfluence;
	#endif
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor.rgb += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,o_=`#ifdef USE_MORPHNORMALS
	objectNormal *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,a_=`#ifdef USE_MORPHTARGETS
	#ifndef USE_INSTANCING_MORPH
		uniform float morphTargetBaseInfluence;
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
	#endif
	uniform sampler2DArray morphTargetsTexture;
	uniform ivec2 morphTargetsTextureSize;
	vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
		int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
		int y = texelIndex / morphTargetsTextureSize.x;
		int x = texelIndex - y * morphTargetsTextureSize.x;
		ivec3 morphUV = ivec3( x, y, morphTargetIndex );
		return texelFetch( morphTargetsTexture, morphUV, 0 );
	}
#endif`,c_=`#ifdef USE_MORPHTARGETS
	transformed *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
	}
#endif`,l_=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );
#else
	vec3 normal = normalize( vNormal );
	#ifdef DOUBLE_SIDED
		normal *= faceDirection;
	#endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
	#ifdef USE_TANGENT
		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);
	#endif
	#ifdef DOUBLE_SIDED
		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;
	#endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	#ifdef USE_TANGENT
		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
	#endif
	#ifdef DOUBLE_SIDED
		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;
	#endif
#endif
vec3 nonPerturbedNormal = normal;`,h_=`#ifdef USE_NORMALMAP_OBJECTSPACE
	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#ifdef FLIP_SIDED
		normal = - normal;
	#endif
	#ifdef DOUBLE_SIDED
		normal = normal * faceDirection;
	#endif
	normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#if defined( USE_PACKED_NORMALMAP )
		mapN = vec3( mapN.xy, sqrt( saturate( 1.0 - dot( mapN.xy, mapN.xy ) ) ) );
	#endif
	mapN.xy *= normalScale;
	normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif`,u_=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,f_=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,d_=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
		#ifdef FLIP_SIDED
			vBitangent = - vBitangent;
		#endif
	#endif
#endif`,p_=`#ifdef USE_NORMALMAP
	uniform sampler2D normalMap;
	uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
	uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
	mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
		vec3 q0 = dFdx( eye_pos.xyz );
		vec3 q1 = dFdy( eye_pos.xyz );
		vec2 st0 = dFdx( uv.st );
		vec2 st1 = dFdy( uv.st );
		vec3 N = surf_norm;
		vec3 q1perp = cross( q1, N );
		vec3 q0perp = cross( N, q0 );
		vec3 T = q1perp * st0.x + q0perp * st1.x;
		vec3 B = q1perp * st0.y + q0perp * st1.y;
		float det = max( dot( T, T ), dot( B, B ) );
		float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
		return mat3( T * scale, B * scale, N );
	}
#endif`,m_=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,g_=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,__=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,x_=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,y_=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,v_=`vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}
vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}
const float PackUpscale = 256. / 255.;const float UnpackDownscale = 255. / 256.;const float ShiftRight8 = 1. / 256.;
const float Inv255 = 1. / 255.;
const vec4 PackFactors = vec4( 1.0, 256.0, 256.0 * 256.0, 256.0 * 256.0 * 256.0 );
const vec2 UnpackFactors2 = vec2( UnpackDownscale, 1.0 / PackFactors.g );
const vec3 UnpackFactors3 = vec3( UnpackDownscale / PackFactors.rg, 1.0 / PackFactors.b );
const vec4 UnpackFactors4 = vec4( UnpackDownscale / PackFactors.rgb, 1.0 / PackFactors.a );
vec4 packDepthToRGBA( const in float v ) {
	if( v <= 0.0 )
		return vec4( 0., 0., 0., 0. );
	if( v >= 1.0 )
		return vec4( 1., 1., 1., 1. );
	float vuf;
	float af = modf( v * PackFactors.a, vuf );
	float bf = modf( vuf * ShiftRight8, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec4( vuf * Inv255, gf * PackUpscale, bf * PackUpscale, af );
}
vec3 packDepthToRGB( const in float v ) {
	if( v <= 0.0 )
		return vec3( 0., 0., 0. );
	if( v >= 1.0 )
		return vec3( 1., 1., 1. );
	float vuf;
	float bf = modf( v * PackFactors.b, vuf );
	float gf = modf( vuf * ShiftRight8, vuf );
	return vec3( vuf * Inv255, gf * PackUpscale, bf );
}
vec2 packDepthToRG( const in float v ) {
	if( v <= 0.0 )
		return vec2( 0., 0. );
	if( v >= 1.0 )
		return vec2( 1., 1. );
	float vuf;
	float gf = modf( v * 256., vuf );
	return vec2( vuf * Inv255, gf );
}
float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors4 );
}
float unpackRGBToDepth( const in vec3 v ) {
	return dot( v, UnpackFactors3 );
}
float unpackRGToDepth( const in vec2 v ) {
	return v.r * UnpackFactors2.r + v.g * UnpackFactors2.g;
}
vec4 pack2HalfToRGBA( const in vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}
vec2 unpackRGBATo2Half( const in vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}
float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {
	#ifdef USE_REVERSED_DEPTH_BUFFER
	
		return depth * ( far - near ) - far;
	#else
		return depth * ( near - far ) - near;
	#endif
}
float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return ( ( near + viewZ ) * far ) / ( ( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	
	#ifdef USE_REVERSED_DEPTH_BUFFER
		return ( near * far ) / ( ( near - far ) * depth - near );
	#else
		return ( near * far ) / ( ( far - near ) * depth - far );
	#endif
}`,M_=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,S_=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,b_=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,T_=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,w_=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,A_=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,E_=`#if NUM_SPOT_LIGHT_COORDS > 0
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#if NUM_SPOT_LIGHT_MAPS > 0
	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_SUN_LIGHT_SHADOWS > 0
		#define SUN_LIGHT_CASCADES 2
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform sampler2DShadow sunShadowMap[ NUM_SUN_LIGHT_SHADOWS ];
		#else
			uniform sampler2D sunShadowMap[ NUM_SUN_LIGHT_SHADOWS ];
		#endif
		uniform mat4 sunShadowMatrix[ NUM_SUN_LIGHT_SHADOWS * SUN_LIGHT_CASCADES ];
		uniform vec4 sunShadowCascade[ NUM_SUN_LIGHT_SHADOWS * SUN_LIGHT_CASCADES ];
		varying vec4 vSunShadowWorldPosition;
		varying vec3 vSunShadowWorldNormal;
		struct SunLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SunLightShadow sunLightShadows[ NUM_SUN_LIGHT_SHADOWS ];
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform sampler2DShadow directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#else
			uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#endif
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform sampler2DShadow spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		#else
			uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		#endif
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#if defined( SHADOWMAP_TYPE_PCF )
			uniform samplerCubeShadow pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		#elif defined( SHADOWMAP_TYPE_BASIC )
			uniform samplerCube pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		#endif
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
	#if defined( SHADOWMAP_TYPE_PCF )
		float interleavedGradientNoise( vec2 position ) {
			return fract( 52.9829189 * fract( dot( position, vec2( 0.06711056, 0.00583715 ) ) ) );
		}
		vec2 vogelDiskSample( int sampleIndex, int samplesCount, float phi ) {
			const float goldenAngle = 2.399963229728653;
			float r = sqrt( ( float( sampleIndex ) + 0.5 ) / float( samplesCount ) );
			float theta = float( sampleIndex ) * goldenAngle + phi;
			return vec2( cos( theta ), sin( theta ) ) * r;
		}
	#endif
	#if defined( SHADOWMAP_TYPE_PCF )
		float getShadow( sampler2DShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
			float shadow = 1.0;
			shadowCoord.xyz /= shadowCoord.w;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				shadowCoord.z -= shadowBias;
			#else
				shadowCoord.z += shadowBias;
			#endif
			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
			if ( frustumTest ) {
				vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
				vec2 radius = shadowRadius * texelSize;
				float phi = interleavedGradientNoise( gl_FragCoord.xy ) * PI2;
				shadow = (
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 0, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 1, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 2, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 3, 5, phi ) * radius, shadowCoord.z ) ) +
					texture( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 4, 5, phi ) * radius, shadowCoord.z ) )
				) * 0.2;
			}
			return mix( 1.0, shadow, shadowIntensity );
		}
	#elif defined( SHADOWMAP_TYPE_VSM )
		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
			float shadow = 1.0;
			shadowCoord.xyz /= shadowCoord.w;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				shadowCoord.z -= shadowBias;
			#else
				shadowCoord.z += shadowBias;
			#endif
			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
			if ( frustumTest ) {
				vec2 distribution = texture2D( shadowMap, shadowCoord.xy ).rg;
				float mean = distribution.x;
				float variance = distribution.y * distribution.y;
				#ifdef USE_REVERSED_DEPTH_BUFFER
					float hard_shadow = step( mean, shadowCoord.z );
				#else
					float hard_shadow = step( shadowCoord.z, mean );
				#endif
				
				if ( hard_shadow == 1.0 ) {
					shadow = 1.0;
				} else {
					variance = max( variance, 0.0000001 );
					float d = shadowCoord.z - mean;
					float p_max = variance / ( variance + d * d );
					p_max = clamp( ( p_max - 0.3 ) / 0.65, 0.0, 1.0 );
					shadow = max( hard_shadow, p_max );
				}
			}
			return mix( 1.0, shadow, shadowIntensity );
		}
	#else
		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
			float shadow = 1.0;
			shadowCoord.xyz /= shadowCoord.w;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				shadowCoord.z -= shadowBias;
			#else
				shadowCoord.z += shadowBias;
			#endif
			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
			if ( frustumTest ) {
				float depth = texture2D( shadowMap, shadowCoord.xy ).r;
				#ifdef USE_REVERSED_DEPTH_BUFFER
					shadow = step( depth, shadowCoord.z );
				#else
					shadow = step( shadowCoord.z, depth );
				#endif
			}
			return mix( 1.0, shadow, shadowIntensity );
		}
	#endif
	#if NUM_SUN_LIGHT_SHADOWS > 0
		float getSunShadow(
			#if defined( SHADOWMAP_TYPE_PCF )
				sampler2DShadow shadowMap,
			#else
				sampler2D shadowMap,
			#endif
			SunLightShadow sunLightShadow,
			int shadowIndex
		) {
			vec4 shadowWorldPosition = vec4( vSunShadowWorldPosition.xyz + vSunShadowWorldNormal * sunLightShadow.shadowNormalBias, 1.0 );
			float viewDepth = vSunShadowWorldPosition.w;
			int cascadeOffset = shadowIndex * SUN_LIGHT_CASCADES;
			float shadow = 1.0;
			for ( int i = SUN_LIGHT_CASCADES - 1; i >= 0; i -- ) {
				vec4 cascade = sunShadowCascade[ cascadeOffset + i ];
				if ( viewDepth >= cascade.x && viewDepth < cascade.y ) {
					float cascadeShadow = getShadow(
						shadowMap,
						sunLightShadow.shadowMapSize,
						sunLightShadow.shadowIntensity,
						sunLightShadow.shadowBias,
						sunLightShadow.shadowRadius,
						sunShadowMatrix[ cascadeOffset + i ] * shadowWorldPosition
					);
					shadow = mix( cascadeShadow, shadow, smoothstep( cascade.z, cascade.y, viewDepth ) );
				}
			}
			return shadow;
		}
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
	#if defined( SHADOWMAP_TYPE_PCF )
	float getPointShadow( samplerCubeShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		float shadow = 1.0;
		vec3 lightToPosition = shadowCoord.xyz;
		vec3 bd3D = normalize( lightToPosition );
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );
		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {
			float lightDistance = length( lightToPosition );
			float depthRange = shadowCameraFar - shadowCameraNear;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				float depthA = - shadowCameraNear / depthRange - shadowBias;
				float depthB = shadowCameraNear * shadowCameraFar / ( depthRange * lightDistance );
			#else
				float depthA = shadowCameraFar / depthRange + shadowBias;
				float depthB = - shadowCameraNear * shadowCameraFar / ( depthRange * lightDistance );
			#endif
			float texelSize = shadowRadius / shadowMapSize.x;
			vec3 absDir = abs( bd3D );
			vec3 tangent = absDir.x > absDir.z ? vec3( 0.0, 1.0, 0.0 ) : vec3( 1.0, 0.0, 0.0 );
			tangent = normalize( cross( bd3D, tangent ) );
			vec3 bitangent = cross( bd3D, tangent );
			float phi = interleavedGradientNoise( gl_FragCoord.xy ) * PI2;
			shadow = 0.0;
			for ( int i = 0; i < 5; i ++ ) {
				vec2 offset = vogelDiskSample( i, 5, phi );
				vec3 direction = bd3D + ( tangent * offset.x + bitangent * offset.y ) * texelSize;
				vec3 absDirection = abs( direction );
				float dp = depthA + depthB / max( max( absDirection.x, absDirection.y ), absDirection.z );
				shadow += texture( shadowMap, vec4( direction, dp ) );
			}
			shadow *= 0.2;
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
	#elif defined( SHADOWMAP_TYPE_BASIC )
	float getPointShadow( samplerCube shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		float shadow = 1.0;
		vec3 lightToPosition = shadowCoord.xyz;
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );
		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {
			float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
			dp += shadowBias;
			vec3 bd3D = normalize( lightToPosition );
			float depth = textureCube( shadowMap, bd3D ).r;
			#ifdef USE_REVERSED_DEPTH_BUFFER
				depth = 1.0 - depth;
			#endif
			shadow = step( dp, depth );
		}
		return mix( 1.0, shadow, shadowIntensity );
	}
	#endif
	#endif
#endif`,R_=`#if NUM_SPOT_LIGHT_COORDS > 0
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_SUN_LIGHT_SHADOWS > 0
		varying vec4 vSunShadowWorldPosition;
		varying vec3 vSunShadowWorldNormal;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		struct SpotLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowIntensity;
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
#endif`,C_=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_SUN_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
	#ifdef HAS_NORMAL
		vec3 shadowWorldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );
	#else
		vec3 shadowWorldNormal = vec3( 0.0 );
	#endif
	vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
	#if NUM_SUN_LIGHT_SHADOWS > 0
		vSunShadowWorldPosition = vec4( worldPosition.xyz, - mvPosition.z );
		vSunShadowWorldNormal = shadowWorldNormal;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * directionalLightShadows[ i ].shadowNormalBias, 0 );
			vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * pointLightShadows[ i ].shadowNormalBias, 0 );
			vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_COORDS; i ++ ) {
		shadowWorldPosition = worldPosition;
		#if ( defined( USE_SHADOWMAP ) && UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
			shadowWorldPosition.xyz += shadowWorldNormal * spotLightShadows[ i ].shadowNormalBias;
		#endif
		vSpotLightCoord[ i ] = spotLightMatrix[ i ] * shadowWorldPosition;
	}
	#pragma unroll_loop_end
#endif`,P_=`float getShadowMask() {
	float shadow = 1.0;
	#ifdef USE_SHADOWMAP
	#if NUM_SUN_LIGHT_SHADOWS > 0
	SunLightShadow sunLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SUN_LIGHT_SHADOWS; i ++ ) {
		sunLight = sunLightShadows[ i ];
		shadow *= receiveShadow ? getSunShadow( sunShadowMap[ i ], sunLight, UNROLLED_LOOP_INDEX ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
		directionalLight = directionalLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowIntensity, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_SHADOWS; i ++ ) {
		spotLight = spotLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowIntensity, spotLight.shadowBias, spotLight.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0 && ( defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_BASIC ) )
	PointLightShadow pointLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
		pointLight = pointLightShadows[ i ];
		shadow *= receiveShadow ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowIntensity, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#endif
	return shadow;
}`,I_=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,L_=`#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	uniform highp sampler2D boneTexture;
	mat4 getBoneMatrix( const in float i ) {
		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,N_=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,D_=`#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif`,U_=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,F_=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,O_=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,B_=`#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
vec3 LinearToneMapping( vec3 color ) {
	return saturate( toneMappingExposure * color );
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
vec3 CineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 RRTAndODTFit( vec3 v ) {
	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ),		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ),		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);
	color *= toneMappingExposure / 0.6;
	color = ACESInputMat * color;
	color = RRTAndODTFit( color );
	color = ACESOutputMat * color;
	return saturate( color );
}
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);
const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);
vec3 agxDefaultContrastApprox( vec3 x ) {
	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;
	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;
}
vec3 AgXToneMapping( vec3 color ) {
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);
	const float AgxMinEv = - 12.47393;	const float AgxMaxEv = 4.026069;
	color *= toneMappingExposure;
	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
	color = AgXInsetMatrix * color;
	color = max( color, 1e-10 );	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
	color = clamp( color, 0.0, 1.0 );
	color = agxDefaultContrastApprox( color );
	color = AgXOutsetMatrix * color;
	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
	color = clamp( color, 0.0, 1.0 );
	return color;
}
vec3 NeutralToneMapping( vec3 color ) {
	const float StartCompression = 0.8 - 0.04;
	const float Desaturation = 0.15;
	color *= toneMappingExposure;
	float x = min( color.r, min( color.g, color.b ) );
	float offset = x < 0.08 ? x - 6.25 * x * x : 0.04;
	color -= offset;
	float peak = max( color.r, max( color.g, color.b ) );
	if ( peak < StartCompression ) return color;
	float d = 1. - StartCompression;
	float newPeak = 1. - d * d / ( peak + d - StartCompression );
	color *= newPeak / peak;
	float g = 1. - 1. / ( Desaturation * ( peak - newPeak ) + 1. );
	return mix( color, vec3( newPeak ), g );
}
vec3 CustomToneMapping( vec3 color ) { return color; }`,z_=`#ifdef USE_TRANSMISSION
	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;
	#endif
	#ifdef USE_THICKNESSMAP
		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;
	#endif
	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = transformNormalByInverseViewMatrix( normal, viewMatrix );
	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseContribution, material.specularColorBlended, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.dispersion, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );
	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );
	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );
#endif`,k_=`#ifdef USE_TRANSMISSION
	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		uniform sampler2D transmissionMap;
	#endif
	#ifdef USE_THICKNESSMAP
		uniform sampler2D thicknessMap;
	#endif
	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;
	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;
	varying vec3 vWorldPosition;
	float w0( float a ) {
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );
	}
	float w1( float a ) {
		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );
	}
	float w2( float a ){
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );
	}
	float w3( float a ) {
		return ( 1.0 / 6.0 ) * ( a * a * a );
	}
	float g0( float a ) {
		return w0( a ) + w1( a );
	}
	float g1( float a ) {
		return w2( a ) + w3( a );
	}
	float h0( float a ) {
		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );
	}
	float h1( float a ) {
		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );
	}
	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {
		uv = uv * texelSize.zw + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );
		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );
	}
	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {
		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );
	}
	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );
		return normalize( refractionVector ) * thickness * modelScale;
	}
	float applyIorToRoughness( const in float roughness, const in float ior ) {
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );
	}
	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {
		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );
	}
	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {
		if ( isinf( attenuationDistance ) ) {
			return vec3( 1.0 );
		} else {
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance );			return transmittance;
		}
	}
	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float dispersion, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {
		vec4 transmittedLight;
		vec3 transmittance;
		#ifdef USE_DISPERSION
			float halfSpread = ( ior - 1.0 ) * 0.025 * dispersion;
			vec3 iors = vec3( ior - halfSpread, ior, ior + halfSpread );
			for ( int i = 0; i < 3; i ++ ) {
				vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, iors[ i ], modelMatrix );
				vec3 refractedRayExit = position + transmissionRay;
				vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
				vec2 refractionCoords = ndcPos.xy / ndcPos.w;
				refractionCoords += 1.0;
				refractionCoords /= 2.0;
				vec4 transmissionSample = getTransmissionSample( refractionCoords, roughness, iors[ i ] );
				transmittedLight[ i ] = transmissionSample[ i ];
				transmittedLight.a += transmissionSample.a;
				transmittance[ i ] = diffuseColor[ i ] * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance )[ i ];
			}
			transmittedLight.a /= 3.0;
		#else
			vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
			vec3 refractedRayExit = position + transmissionRay;
			vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
			vec2 refractionCoords = ndcPos.xy / ndcPos.w;
			refractionCoords += 1.0;
			refractionCoords /= 2.0;
			transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
			transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );
		#endif
		vec3 attenuatedColor = transmittance * transmittedLight.rgb;
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;
		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );
	}
#endif`,V_=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_DIFFUSE_ROUGHNESSMAP
	varying vec2 vDiffuseRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,G_=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	uniform mat3 mapTransform;
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	uniform mat3 alphaMapTransform;
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	uniform mat3 lightMapTransform;
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	uniform mat3 aoMapTransform;
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	uniform mat3 bumpMapTransform;
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	uniform mat3 normalMapTransform;
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_DISPLACEMENTMAP
	uniform mat3 displacementMapTransform;
	varying vec2 vDisplacementMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	uniform mat3 emissiveMapTransform;
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	uniform mat3 metalnessMapTransform;
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	uniform mat3 roughnessMapTransform;
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_DIFFUSE_ROUGHNESSMAP
	uniform mat3 diffuseRoughnessMapTransform;
	varying vec2 vDiffuseRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	uniform mat3 anisotropyMapTransform;
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	uniform mat3 clearcoatMapTransform;
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform mat3 clearcoatNormalMapTransform;
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform mat3 clearcoatRoughnessMapTransform;
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	uniform mat3 sheenColorMapTransform;
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	uniform mat3 sheenRoughnessMapTransform;
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	uniform mat3 iridescenceMapTransform;
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform mat3 iridescenceThicknessMapTransform;
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SPECULARMAP
	uniform mat3 specularMapTransform;
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	uniform mat3 specularColorMapTransform;
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	uniform mat3 specularIntensityMapTransform;
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,H_=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	vUv = vec3( uv, 1 ).xy;
#endif
#ifdef USE_MAP
	vMapUv = ( mapTransform * vec3( MAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ALPHAMAP
	vAlphaMapUv = ( alphaMapTransform * vec3( ALPHAMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_LIGHTMAP
	vLightMapUv = ( lightMapTransform * vec3( LIGHTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_AOMAP
	vAoMapUv = ( aoMapTransform * vec3( AOMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_BUMPMAP
	vBumpMapUv = ( bumpMapTransform * vec3( BUMPMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_NORMALMAP
	vNormalMapUv = ( normalMapTransform * vec3( NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DISPLACEMENTMAP
	vDisplacementMapUv = ( displacementMapTransform * vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_EMISSIVEMAP
	vEmissiveMapUv = ( emissiveMapTransform * vec3( EMISSIVEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_METALNESSMAP
	vMetalnessMapUv = ( metalnessMapTransform * vec3( METALNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ROUGHNESSMAP
	vRoughnessMapUv = ( roughnessMapTransform * vec3( ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DIFFUSE_ROUGHNESSMAP
	vDiffuseRoughnessMapUv = ( diffuseRoughnessMapTransform * vec3( DIFFUSE_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ANISOTROPYMAP
	vAnisotropyMapUv = ( anisotropyMapTransform * vec3( ANISOTROPYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOATMAP
	vClearcoatMapUv = ( clearcoatMapTransform * vec3( CLEARCOATMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	vClearcoatNormalMapUv = ( clearcoatNormalMapTransform * vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	vClearcoatRoughnessMapUv = ( clearcoatRoughnessMapTransform * vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCEMAP
	vIridescenceMapUv = ( iridescenceMapTransform * vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	vIridescenceThicknessMapUv = ( iridescenceThicknessMapTransform * vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_COLORMAP
	vSheenColorMapUv = ( sheenColorMapTransform * vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	vSheenRoughnessMapUv = ( sheenRoughnessMapTransform * vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULARMAP
	vSpecularMapUv = ( specularMapTransform * vec3( SPECULARMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_COLORMAP
	vSpecularColorMapUv = ( specularColorMapTransform * vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	vSpecularIntensityMapUv = ( specularIntensityMapTransform * vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_TRANSMISSIONMAP
	vTransmissionMapUv = ( transmissionMapTransform * vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_THICKNESSMAP
	vThicknessMapUv = ( thicknessMapTransform * vec3( THICKNESSMAP_UV, 1 ) ).xy;
#endif`,W_=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`,X_=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,q_=`uniform sampler2D t2D;
uniform float backgroundIntensity;
varying vec2 vUv;
void main() {
	vec4 texColor = texture2D( t2D, vUv );
	#ifdef DECODE_VIDEO_TEXTURE
		texColor = vec4( mix( pow( texColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), texColor.rgb * 0.0773993808, vec3( lessThanEqual( texColor.rgb, vec3( 0.04045 ) ) ) ), texColor.w );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Y_=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,K_=`uniform float backgroundBlurriness;
uniform float backgroundIntensity;
uniform mat3 backgroundRotation;
varying vec3 vWorldDirection;
#include <envmap_common_pars_fragment>
void main() {
	#ifdef ENVMAP_TYPE_PMREM
		vec4 texColor = textureLod( envMap, backgroundRotation * vWorldDirection, roughnessToMip( backgroundBlurriness ) );
	#else
		vec4 texColor = textureCube( envMap, backgroundRotation * vWorldDirection );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Z_=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,J_=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,$_=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
varying vec2 vHighPrecisionZW;
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vHighPrecisionZW = gl_Position.zw;
}`,j_=`#if DEPTH_PACKING == 3200
	uniform float opacity;
#endif
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
varying vec2 vHighPrecisionZW;
void main() {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#if DEPTH_PACKING == 3200
		diffuseColor.a = opacity;
	#endif
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <logdepthbuf_fragment>
	#ifdef USE_REVERSED_DEPTH_BUFFER
		float fragCoordZ = vHighPrecisionZW[ 0 ] / vHighPrecisionZW[ 1 ];
	#else
		float fragCoordZ = 0.5 * vHighPrecisionZW[ 0 ] / vHighPrecisionZW[ 1 ] + 0.5;
	#endif
	#if DEPTH_PACKING == 3200
		gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );
	#elif DEPTH_PACKING == 3201
		gl_FragColor = packDepthToRGBA( fragCoordZ );
	#elif DEPTH_PACKING == 3202
		gl_FragColor = vec4( packDepthToRGB( fragCoordZ ), 1.0 );
	#elif DEPTH_PACKING == 3203
		gl_FragColor = vec4( packDepthToRG( fragCoordZ ), 0.0, 1.0 );
	#endif
}`,Q_=`#define DISTANCE
varying vec3 vWorldPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#include <morphinstance_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	vWorldPosition = worldPosition.xyz;
}`,tx=`#define DISTANCE
uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( 1.0 );
	#include <clipping_planes_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist );
	gl_FragColor = vec4( dist, 0.0, 0.0, 1.0 );
}`,ex=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,nx=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,ix=`uniform float scale;
attribute float lineDistance;
varying float vLineDistance;
#include <common>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	vLineDistance = scale * lineDistance;
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,sx=`uniform vec3 diffuse;
uniform float opacity;
uniform float dashSize;
uniform float totalSize;
varying float vLineDistance;
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	if ( mod( vLineDistance, totalSize ) > dashSize ) {
		discard;
	}
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,rx=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#if defined ( USE_ENVMAP ) || defined ( USE_SKINNING )
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinbase_vertex>
		#include <skinnormal_vertex>
		#include <defaultnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>
}`,ox=`uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
	varying vec3 vNormal;
#endif
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
	#else
		reflectedLight.indirectDiffuse += vec3( 1.0 );
	#endif
	#include <aomap_fragment>
	reflectedLight.indirectDiffuse *= diffuseColor.rgb;
	vec3 outgoingLight = reflectedLight.indirectDiffuse;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,ax=`#define LAMBERT
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,cx=`#define LAMBERT
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_lambert_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,lx=`#define MATCAP
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
	vViewPosition = - mvPosition.xyz;
}`,hx=`#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
	#ifdef USE_MATCAP
		vec4 matcapColor = texture2D( matcap, uv );
	#else
		vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
	#endif
	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,ux=`#define NORMAL
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	vViewPosition = - mvPosition.xyz;
#endif
}`,fx=`#define NORMAL
uniform float opacity;
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <uv_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( 0.0, 0.0, 0.0, opacity );
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	gl_FragColor = vec4( normalize( normal ) * 0.5 + 0.5, diffuseColor.a );
	#ifdef OPAQUE
		gl_FragColor.a = 1.0;
	#endif
}`,dx=`#define PHONG
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,px=`#define PHONG
uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,mx=`#define STANDARD
varying vec3 vViewPosition;
#ifdef USE_TRANSMISSION
	varying vec3 vWorldPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
#ifdef USE_TRANSMISSION
	vWorldPosition = worldPosition.xyz;
#endif
}`,gx=`#define STANDARD
#ifdef PHYSICAL
	#define IOR
	#define USE_SPECULAR
#endif
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
#ifdef IOR
	uniform float ior;
#endif
#ifdef USE_SPECULAR
	uniform float specularIntensity;
	uniform vec3 specularColor;
	#ifdef USE_SPECULAR_COLORMAP
		uniform sampler2D specularColorMap;
	#endif
	#ifdef USE_SPECULAR_INTENSITYMAP
		uniform sampler2D specularIntensityMap;
	#endif
#endif
#ifdef USE_CLEARCOAT
	uniform float clearcoat;
	uniform float clearcoatRoughness;
#endif
#ifdef USE_DIFFUSE_ROUGHNESS
	uniform float diffuseRoughness;
	#ifdef USE_DIFFUSE_ROUGHNESSMAP
		uniform sampler2D diffuseRoughnessMap;
	#endif
#endif
#ifdef USE_DISPERSION
	uniform float dispersion;
#endif
#ifdef USE_RETROREFLECTION
	uniform float retroreflectivity;
#endif
#ifdef USE_IRIDESCENCE
	uniform float iridescence;
	uniform float iridescenceIOR;
	uniform float iridescenceThicknessMinimum;
	uniform float iridescenceThicknessMaximum;
#endif
#ifdef USE_SHEEN
	uniform vec3 sheenColor;
	uniform float sheenRoughness;
	#ifdef USE_SHEEN_COLORMAP
		uniform sampler2D sheenColorMap;
	#endif
	#ifdef USE_SHEEN_ROUGHNESSMAP
		uniform sampler2D sheenRoughnessMap;
	#endif
#endif
#ifdef USE_ANISOTROPY
	uniform vec2 anisotropyVector;
	#ifdef USE_ANISOTROPYMAP
		uniform sampler2D anisotropyMap;
	#endif
#endif
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <iridescence_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <transmission_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <clearcoat_pars_fragment>
#include <iridescence_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <clearcoat_normal_fragment_begin>
	#include <clearcoat_normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
	vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;
	#include <transmission_fragment>
	vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;
	#ifdef USE_SHEEN
 
		outgoingLight = outgoingLight + sheenSpecularDirect + sheenSpecularIndirect;
 
 	#endif
	#ifdef USE_CLEARCOAT
		float dotNVcc = saturate( dot( geometryClearcoatNormal, geometryViewDir ) );
		vec3 Fcc = F_Schlick( material.clearcoatF0, material.clearcoatF90, dotNVcc );
		outgoingLight = outgoingLight * ( 1.0 - material.clearcoat * Fcc ) + ( clearcoatSpecularDirect + clearcoatSpecularIndirect ) * material.clearcoat;
	#endif
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,_x=`#define TOON
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,xx=`#define TOON
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_toon_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_toon_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,yx=`uniform float size;
uniform float scale;
#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
#ifdef USE_POINTS_UV
	varying vec2 vUv;
	uniform mat3 uvTransform;
#endif
void main() {
	#ifdef USE_POINTS_UV
		vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	#endif
	#include <color_vertex>
	#include <morphinstance_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	gl_PointSize = size;
	#ifdef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
	#endif
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>
}`,vx=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,Mx=`#include <common>
#include <batching_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <shadowmap_pars_vertex>
void main() {
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphinstance_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Sx=`uniform vec3 color;
uniform float opacity;
#include <common>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <logdepthbuf_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
void main() {
	#include <logdepthbuf_fragment>
	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,bx=`uniform float rotation;
uniform vec2 center;
#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	vec4 mvPosition = modelViewMatrix[ 3 ];
	vec2 scale = vec2( length( modelMatrix[ 0 ].xyz ), length( modelMatrix[ 1 ].xyz ) );
	#ifndef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) scale *= - mvPosition.z;
	#endif
	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;
	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;
	mvPosition.xy += rotatedPosition;
	gl_Position = projectionMatrix * mvPosition;
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,Tx=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Nt={alphahash_fragment:qg,alphahash_pars_fragment:Yg,alphamap_fragment:Kg,alphamap_pars_fragment:Zg,alphatest_fragment:Jg,alphatest_pars_fragment:$g,aomap_fragment:jg,aomap_pars_fragment:Qg,batching_pars_vertex:t0,batching_vertex:e0,begin_vertex:n0,beginnormal_vertex:i0,bsdfs:s0,iridescence_fragment:r0,bumpmap_pars_fragment:o0,clipping_planes_fragment:a0,clipping_planes_pars_fragment:c0,clipping_planes_pars_vertex:l0,clipping_planes_vertex:h0,color_fragment:u0,color_pars_fragment:f0,color_pars_vertex:d0,color_vertex:p0,common:m0,defaultnormal_vertex:g0,displacementmap_pars_vertex:_0,displacementmap_vertex:x0,emissivemap_fragment:y0,emissivemap_pars_fragment:v0,colorspace_fragment:M0,colorspace_pars_fragment:S0,envmap_fragment:b0,envmap_common_pars_fragment:T0,envmap_pars_fragment:w0,envmap_pars_vertex:A0,envmap_physical_pars_fragment:O0,envmap_vertex:E0,fog_vertex:R0,fog_pars_vertex:C0,fog_fragment:P0,fog_pars_fragment:I0,gradientmap_pars_fragment:L0,lightmap_pars_fragment:N0,lights_lambert_fragment:D0,lights_lambert_pars_fragment:U0,lights_pars_begin:F0,lights_toon_fragment:B0,lights_toon_pars_fragment:z0,lights_phong_fragment:k0,lights_phong_pars_fragment:V0,lights_physical_fragment:G0,lights_physical_pars_fragment:H0,lights_fragment_begin:W0,lights_fragment_maps:X0,lights_fragment_end:q0,lightprobes_pars_fragment:Y0,logdepthbuf_fragment:K0,logdepthbuf_pars_fragment:Z0,logdepthbuf_pars_vertex:J0,logdepthbuf_vertex:$0,map_fragment:j0,map_pars_fragment:Q0,map_particle_fragment:t_,map_particle_pars_fragment:e_,metalnessmap_fragment:n_,metalnessmap_pars_fragment:i_,morphinstance_vertex:s_,morphcolor_vertex:r_,morphnormal_vertex:o_,morphtarget_pars_vertex:a_,morphtarget_vertex:c_,normal_fragment_begin:l_,normal_fragment_maps:h_,normal_pars_fragment:u_,normal_pars_vertex:f_,normal_vertex:d_,normalmap_pars_fragment:p_,clearcoat_normal_fragment_begin:m_,clearcoat_normal_fragment_maps:g_,clearcoat_pars_fragment:__,iridescence_pars_fragment:x_,opaque_fragment:y_,packing:v_,premultiplied_alpha_fragment:M_,project_vertex:S_,dithering_fragment:b_,dithering_pars_fragment:T_,roughnessmap_fragment:w_,roughnessmap_pars_fragment:A_,shadowmap_pars_fragment:E_,shadowmap_pars_vertex:R_,shadowmap_vertex:C_,shadowmask_pars_fragment:P_,skinbase_vertex:I_,skinning_pars_vertex:L_,skinning_vertex:N_,skinnormal_vertex:D_,specularmap_fragment:U_,specularmap_pars_fragment:F_,tonemapping_fragment:O_,tonemapping_pars_fragment:B_,transmission_fragment:z_,transmission_pars_fragment:k_,uv_pars_fragment:V_,uv_pars_vertex:G_,uv_vertex:H_,worldpos_vertex:W_,background_vert:X_,background_frag:q_,backgroundCube_vert:Y_,backgroundCube_frag:K_,cube_vert:Z_,cube_frag:J_,depth_vert:$_,depth_frag:j_,distance_vert:Q_,distance_frag:tx,equirect_vert:ex,equirect_frag:nx,linedashed_vert:ix,linedashed_frag:sx,meshbasic_vert:rx,meshbasic_frag:ox,meshlambert_vert:ax,meshlambert_frag:cx,meshmatcap_vert:lx,meshmatcap_frag:hx,meshnormal_vert:ux,meshnormal_frag:fx,meshphong_vert:dx,meshphong_frag:px,meshphysical_vert:mx,meshphysical_frag:gx,meshtoon_vert:_x,meshtoon_frag:xx,points_vert:yx,points_frag:vx,shadow_vert:Mx,shadow_frag:Sx,sprite_vert:bx,sprite_frag:Tx},mt={common:{diffuse:{value:new Pt(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new Ft},alphaMap:{value:null},alphaMapTransform:{value:new Ft},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new Ft}},envmap:{envMap:{value:null},envMapRotation:{value:new Ft},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98},dfgLUT:{value:null}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new Ft}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new Ft}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new Ft},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new Ft},normalScale:{value:new At(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new Ft},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new Ft}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new Ft}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new Ft}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new Pt(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},sunLights:{value:[],properties:{direction:{},color:{}}},sunLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},sunShadowMatrix:{value:[]},sunShadowCascade:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowIntensity:1,shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null},probesSH:{value:[]},probesMin:{value:[]},probesMax:{value:[]},probesResolution:{value:[]}},points:{diffuse:{value:new Pt(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new Ft},alphaTest:{value:0},uvTransform:{value:new Ft}},sprite:{diffuse:{value:new Pt(16777215)},opacity:{value:1},center:{value:new At(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new Ft},alphaMap:{value:null},alphaMapTransform:{value:new Ft},alphaTest:{value:0}}},ci={basic:{uniforms:ln([mt.common,mt.specularmap,mt.envmap,mt.aomap,mt.lightmap,mt.fog]),vertexShader:Nt.meshbasic_vert,fragmentShader:Nt.meshbasic_frag},lambert:{uniforms:ln([mt.common,mt.specularmap,mt.envmap,mt.aomap,mt.lightmap,mt.emissivemap,mt.bumpmap,mt.normalmap,mt.displacementmap,mt.fog,mt.lights,{emissive:{value:new Pt(0)},envMapIntensity:{value:1}}]),vertexShader:Nt.meshlambert_vert,fragmentShader:Nt.meshlambert_frag},phong:{uniforms:ln([mt.common,mt.specularmap,mt.envmap,mt.aomap,mt.lightmap,mt.emissivemap,mt.bumpmap,mt.normalmap,mt.displacementmap,mt.fog,mt.lights,{emissive:{value:new Pt(0)},specular:{value:new Pt(1118481)},shininess:{value:30},envMapIntensity:{value:1}}]),vertexShader:Nt.meshphong_vert,fragmentShader:Nt.meshphong_frag},standard:{uniforms:ln([mt.common,mt.envmap,mt.aomap,mt.lightmap,mt.emissivemap,mt.bumpmap,mt.normalmap,mt.displacementmap,mt.roughnessmap,mt.metalnessmap,mt.fog,mt.lights,{emissive:{value:new Pt(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Nt.meshphysical_vert,fragmentShader:Nt.meshphysical_frag},toon:{uniforms:ln([mt.common,mt.aomap,mt.lightmap,mt.emissivemap,mt.bumpmap,mt.normalmap,mt.displacementmap,mt.gradientmap,mt.fog,mt.lights,{emissive:{value:new Pt(0)}}]),vertexShader:Nt.meshtoon_vert,fragmentShader:Nt.meshtoon_frag},matcap:{uniforms:ln([mt.common,mt.bumpmap,mt.normalmap,mt.displacementmap,mt.fog,{matcap:{value:null}}]),vertexShader:Nt.meshmatcap_vert,fragmentShader:Nt.meshmatcap_frag},points:{uniforms:ln([mt.points,mt.fog]),vertexShader:Nt.points_vert,fragmentShader:Nt.points_frag},dashed:{uniforms:ln([mt.common,mt.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Nt.linedashed_vert,fragmentShader:Nt.linedashed_frag},depth:{uniforms:ln([mt.common,mt.displacementmap]),vertexShader:Nt.depth_vert,fragmentShader:Nt.depth_frag},normal:{uniforms:ln([mt.common,mt.bumpmap,mt.normalmap,mt.displacementmap,{opacity:{value:1}}]),vertexShader:Nt.meshnormal_vert,fragmentShader:Nt.meshnormal_frag},sprite:{uniforms:ln([mt.sprite,mt.fog]),vertexShader:Nt.sprite_vert,fragmentShader:Nt.sprite_frag},background:{uniforms:{uvTransform:{value:new Ft},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Nt.background_vert,fragmentShader:Nt.background_frag},backgroundCube:{uniforms:{envMap:{value:null},backgroundBlurriness:{value:0},backgroundIntensity:{value:1},backgroundRotation:{value:new Ft}},vertexShader:Nt.backgroundCube_vert,fragmentShader:Nt.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Nt.cube_vert,fragmentShader:Nt.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Nt.equirect_vert,fragmentShader:Nt.equirect_frag},distance:{uniforms:ln([mt.common,mt.displacementmap,{referencePosition:{value:new R},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Nt.distance_vert,fragmentShader:Nt.distance_frag},shadow:{uniforms:ln([mt.lights,mt.fog,{color:{value:new Pt(0)},opacity:{value:1}}]),vertexShader:Nt.shadow_vert,fragmentShader:Nt.shadow_frag}};ci.physical={uniforms:ln([ci.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new Ft},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new Ft},clearcoatNormalScale:{value:new At(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new Ft},diffuseRoughness:{value:0},diffuseRoughnessMap:{value:null},diffuseRoughnessMapTransform:{value:new Ft},dispersion:{value:0},retroreflectivity:{value:0},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new Ft},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new Ft},sheen:{value:0},sheenColor:{value:new Pt(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new Ft},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new Ft},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new Ft},transmissionSamplerSize:{value:new At},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new Ft},attenuationDistance:{value:0},attenuationColor:{value:new Pt(0)},specularColor:{value:new Pt(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new Ft},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new Ft},anisotropyVector:{value:new At},anisotropyMap:{value:null},anisotropyMapTransform:{value:new Ft}}]),vertexShader:Nt.meshphysical_vert,fragmentShader:Nt.meshphysical_frag};var Wc={r:0,b:0,g:0},wx=new _t,bp=new Ft;bp.set(-1,0,0,0,1,0,0,0,1);function Ax(s,t,e,n,i,r){let o=new Pt(0),a=i===!0?0:1,c,l,h=null,f=0,u=null;function d(x){let M=x.isScene===!0?x.background:null;if(M&&M.isTexture){let y=x.backgroundBlurriness>0;M=t.get(M,y)}return M}function g(x){let M=!1,y=d(x);y===null?m(o,a):y&&y.isColor&&(m(y,1),M=!0);let S=s.xr.getEnvironmentBlendMode();S==="additive"?e.buffers.color.setClear(0,0,0,1,r):S==="alpha-blend"&&e.buffers.color.setClear(0,0,0,0,r),(s.autoClear||M)&&(e.buffers.depth.setTest(!0),e.buffers.depth.setMask(!0),e.buffers.color.setMask(!0),s.clear(s.autoClearColor,s.autoClearDepth,s.autoClearStencil))}function v(x,M){let y=d(M);y&&y.isCubeTexture?(l===void 0&&(l=new Ee(new dr(1,1,1),new ei({name:"BackgroundCubeMaterial",uniforms:Cs(ci.backgroundCube.uniforms),vertexShader:ci.backgroundCube.vertexShader,fragmentShader:ci.backgroundCube.fragmentShader,side:Ne,depthTest:!1,depthWrite:!1,fog:!1,allowOverride:!1})),l.geometry.deleteAttribute("normal"),l.geometry.deleteAttribute("uv"),l.onBeforeRender=function(S,T,_){this.matrixWorld.copyPosition(_.matrixWorld)},Object.defineProperty(l.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),n.update(l)),l.material.uniforms.envMap.value=y,l.material.uniforms.backgroundBlurriness.value=M.backgroundBlurriness,l.material.uniforms.backgroundIntensity.value=M.backgroundIntensity,l.material.uniforms.backgroundRotation.value.setFromMatrix4(wx.makeRotationFromEuler(M.backgroundRotation)).transpose(),y.isRenderTargetTexture===!1&&l.material.uniforms.backgroundRotation.value.premultiply(bp),l.material.toneMapped=Ht.getTransfer(y.colorSpace)!==se,(h!==y||f!==y.version||u!==s.toneMapping)&&(l.material.needsUpdate=!0,h=y,f=y.version,u=s.toneMapping),l.layers.enableAll(),x.unshift(l,l.geometry,l.material,0,0,null)):y&&y.isTexture&&(c===void 0&&(c=new Ee(new Ri(2,2),new ei({name:"BackgroundMaterial",uniforms:Cs(ci.background.uniforms),vertexShader:ci.background.vertexShader,fragmentShader:ci.background.fragmentShader,side:pn,depthTest:!1,depthWrite:!1,fog:!1,allowOverride:!1})),c.geometry.deleteAttribute("normal"),Object.defineProperty(c.material,"map",{get:function(){return this.uniforms.t2D.value}}),n.update(c)),c.material.uniforms.t2D.value=y,c.material.uniforms.backgroundIntensity.value=M.backgroundIntensity,c.material.toneMapped=Ht.getTransfer(y.colorSpace)!==se,y.matrixAutoUpdate===!0&&y.updateMatrix(),c.material.uniforms.uvTransform.value.copy(y.matrix),(h!==y||f!==y.version||u!==s.toneMapping)&&(c.material.needsUpdate=!0,h=y,f=y.version,u=s.toneMapping),c.layers.enableAll(),x.unshift(c,c.geometry,c.material,0,0,null))}function m(x,M){x.getRGB(Wc,Wh(s)),e.buffers.color.setClear(Wc.r,Wc.g,Wc.b,M,r)}function p(){l!==void 0&&(l.geometry.dispose(),l.material.dispose(),l=void 0),c!==void 0&&(c.geometry.dispose(),c.material.dispose(),c=void 0)}return{getClearColor:function(){return o},setClearColor:function(x,M=1){o.set(x),a=M,m(o,a)},getClearAlpha:function(){return a},setClearAlpha:function(x){a=x,m(o,a)},render:g,addToRenderList:v,dispose:p}}function Ex(s,t){let e=s.getParameter(s.MAX_VERTEX_ATTRIBS),n={},i=u(null),r=i,o=!1;function a(L,C,U,N,B){let G=!1,H=f(L,N,U,C);r!==H&&(r=H,l(r.object)),G=d(L,N,U,B),G&&g(L,N,U,B),B!==null&&t.update(B,s.ELEMENT_ARRAY_BUFFER),(G||o)&&(o=!1,y(L,C,U,N),B!==null&&s.bindBuffer(s.ELEMENT_ARRAY_BUFFER,t.get(B).buffer))}function c(){return s.createVertexArray()}function l(L){return s.bindVertexArray(L)}function h(L){return s.deleteVertexArray(L)}function f(L,C,U,N){let B=N.wireframe===!0,G=n[C.id];G===void 0&&(G={},n[C.id]=G);let H=L.isInstancedMesh===!0?L.id:0,tt=G[H];tt===void 0&&(tt={},G[H]=tt);let X=tt[U.id];X===void 0&&(X={},tt[U.id]=X);let j=X[B];return j===void 0&&(j=u(c()),X[B]=j),j}function u(L){let C=[],U=[],N=[];for(let B=0;B<e;B++)C[B]=0,U[B]=0,N[B]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:C,enabledAttributes:U,attributeDivisors:N,object:L,attributes:{},index:null}}function d(L,C,U,N){let B=r.attributes,G=C.attributes,H=0,tt=U.getAttributes();for(let X in tt)if(tt[X].location>=0){let Q=B[X],yt=G[X];if(yt===void 0&&(X==="instanceMatrix"&&L.instanceMatrix&&(yt=L.instanceMatrix),X==="instanceColor"&&L.instanceColor&&(yt=L.instanceColor)),Q===void 0||Q.attribute!==yt||yt&&Q.data!==yt.data)return!0;H++}return r.attributesNum!==H||r.index!==N}function g(L,C,U,N){let B={},G=C.attributes,H=0,tt=U.getAttributes();for(let X in tt)if(tt[X].location>=0){let Q=G[X];Q===void 0&&(X==="instanceMatrix"&&L.instanceMatrix&&(Q=L.instanceMatrix),X==="instanceColor"&&L.instanceColor&&(Q=L.instanceColor));let yt={};yt.attribute=Q,Q&&Q.data&&(yt.data=Q.data),B[X]=yt,H++}r.attributes=B,r.attributesNum=H,r.index=N}function v(){let L=r.newAttributes;for(let C=0,U=L.length;C<U;C++)L[C]=0}function m(L){p(L,0)}function p(L,C){let U=r.newAttributes,N=r.enabledAttributes,B=r.attributeDivisors;U[L]=1,N[L]===0&&(s.enableVertexAttribArray(L),N[L]=1),B[L]!==C&&(s.vertexAttribDivisor(L,C),B[L]=C)}function x(){let L=r.newAttributes,C=r.enabledAttributes;for(let U=0,N=C.length;U<N;U++)C[U]!==L[U]&&(s.disableVertexAttribArray(U),C[U]=0)}function M(L,C,U,N,B,G,H){H===!0?s.vertexAttribIPointer(L,C,U,B,G):s.vertexAttribPointer(L,C,U,N,B,G)}function y(L,C,U,N){v();let B=N.attributes,G=U.getAttributes(),H=C.defaultAttributeValues;for(let tt in G){let X=G[tt];if(X.location>=0){let j=B[tt];if(j===void 0&&(tt==="instanceMatrix"&&L.instanceMatrix&&(j=L.instanceMatrix),tt==="instanceColor"&&L.instanceColor&&(j=L.instanceColor)),j!==void 0){let Q=j.normalized,yt=j.itemSize,Ut=t.get(j);if(Ut===void 0)continue;let Z=Ut.buffer,lt=Ut.type,xt=Ut.bytesPerElement,Ct=lt===s.INT||lt===s.UNSIGNED_INT||j.gpuType===rc;if(j.isInterleavedBufferAttribute){let dt=j.data,Ot=dt.isInterleavedBuffer===!0?dt.stride:dt.itemSize,Ce=j.offset;if(dt.isInstancedInterleavedBuffer||dt.isInstancedBufferAttribute){for(let It=0;It<X.locationSize;It++)p(X.location+It,dt.meshPerAttribute);L.isInstancedMesh!==!0&&N._maxInstanceCount===void 0&&(N._maxInstanceCount=dt.meshPerAttribute*dt.count)}else for(let It=0;It<X.locationSize;It++)m(X.location+It);s.bindBuffer(s.ARRAY_BUFFER,Z);for(let It=0;It<X.locationSize;It++)M(X.location+It,yt/X.locationSize,lt,Q,Ot*xt,(Ce+yt/X.locationSize*It)*xt,Ct)}else{if(j.isInstancedBufferAttribute){for(let dt=0;dt<X.locationSize;dt++)p(X.location+dt,j.meshPerAttribute);L.isInstancedMesh!==!0&&N._maxInstanceCount===void 0&&(N._maxInstanceCount=j.meshPerAttribute*j.count)}else for(let dt=0;dt<X.locationSize;dt++)m(X.location+dt);s.bindBuffer(s.ARRAY_BUFFER,Z);for(let dt=0;dt<X.locationSize;dt++)M(X.location+dt,yt/X.locationSize,lt,Q,yt*xt,yt/X.locationSize*dt*xt,Ct)}}else if(H!==void 0){let Q=H[tt];if(Q!==void 0)switch(Q.length){case 2:s.vertexAttrib2fv(X.location,Q);break;case 3:s.vertexAttrib3fv(X.location,Q);break;case 4:s.vertexAttrib4fv(X.location,Q);break;default:s.vertexAttrib1fv(X.location,Q)}}}}x()}function S(){I();for(let L in n){let C=n[L];for(let U in C){let N=C[U];for(let B in N){let G=N[B];for(let H in G)h(G[H].object),delete G[H];delete N[B]}}delete n[L]}}function T(L){if(n[L.id]===void 0)return;let C=n[L.id];for(let U in C){let N=C[U];for(let B in N){let G=N[B];for(let H in G)h(G[H].object),delete G[H];delete N[B]}}delete n[L.id]}function _(L){for(let C in n){let U=n[C];for(let N in U){let B=U[N];if(B[L.id]===void 0)continue;let G=B[L.id];for(let H in G)h(G[H].object),delete G[H];delete B[L.id]}}}function b(L){for(let C in n){let U=n[C],N=L.isInstancedMesh===!0?L.id:0,B=U[N];if(B!==void 0){for(let G in B){let H=B[G];for(let tt in H)h(H[tt].object),delete H[tt];delete B[G]}delete U[N],Object.keys(U).length===0&&delete n[C]}}}function I(){E(),o=!0,r!==i&&(r=i,l(r.object))}function E(){i.geometry=null,i.program=null,i.wireframe=!1}return{setup:a,reset:I,resetDefaultState:E,dispose:S,releaseStatesOfGeometry:T,releaseStatesOfObject:b,releaseStatesOfProgram:_,initAttributes:v,enableAttribute:m,disableUnusedAttributes:x}}function Rx(s,t,e){let n;function i(c){n=c}function r(c,l){s.drawArrays(n,c,l),e.update(l,n,1)}function o(c,l,h){h!==0&&(s.drawArraysInstanced(n,c,l,h),e.update(l,n,h))}function a(c,l,h){if(h===0)return;t.get("WEBGL_multi_draw").multiDrawArraysWEBGL(n,c,0,l,0,h);let u=0;for(let d=0;d<h;d++)u+=l[d];e.update(u,n,1)}this.setMode=i,this.render=r,this.renderInstances=o,this.renderMultiDraw=a}function Cx(s,t,e,n){let i;function r(){if(i!==void 0)return i;if(t.has("EXT_texture_filter_anisotropic")===!0){let _=t.get("EXT_texture_filter_anisotropic");i=s.getParameter(_.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else i=0;return i}function o(_){return!(_!==Fn&&n.convert(_)!==s.getParameter(s.IMPLEMENTATION_COLOR_READ_FORMAT))}function a(_){let b=_===cn&&(t.has("EXT_color_buffer_half_float")||t.has("EXT_color_buffer_float"));return!(_!==an&&_!==An&&!b&&n.convert(_)!==s.getParameter(s.IMPLEMENTATION_COLOR_READ_TYPE))}function c(_){if(_==="highp"){if(s.getShaderPrecisionFormat(s.VERTEX_SHADER,s.HIGH_FLOAT).precision>0&&s.getShaderPrecisionFormat(s.FRAGMENT_SHADER,s.HIGH_FLOAT).precision>0)return"highp";_="mediump"}return _==="mediump"&&s.getShaderPrecisionFormat(s.VERTEX_SHADER,s.MEDIUM_FLOAT).precision>0&&s.getShaderPrecisionFormat(s.FRAGMENT_SHADER,s.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}let l=e.precision!==void 0?e.precision:"highp",h=c(l);h!==l&&(Tt("WebGLRenderer:",l,"not supported, using",h,"instead."),l=h);let f=e.reversedDepthBuffer===!0&&t.has("EXT_clip_control"),u=e.logarithmicDepthBuffer===!0&&f===!1;e.reversedDepthBuffer===!0&&f===!1&&Tt("WebGLRenderer: Unable to use reversed depth buffer due to missing EXT_clip_control extension. Fallback to default depth buffer."),e.logarithmicDepthBuffer===!0&&f===!0&&Tt("WebGLRenderer: Logarithmic depth buffer is ignored when reversed depth buffer is enabled.");let d=s.getParameter(s.MAX_TEXTURE_IMAGE_UNITS),g=s.getParameter(s.MAX_VERTEX_TEXTURE_IMAGE_UNITS),v=s.getParameter(s.MAX_TEXTURE_SIZE),m=s.getParameter(s.MAX_CUBE_MAP_TEXTURE_SIZE),p=s.getParameter(s.MAX_VERTEX_ATTRIBS),x=s.getParameter(s.MAX_VERTEX_UNIFORM_VECTORS),M=s.getParameter(s.MAX_VARYING_VECTORS),y=s.getParameter(s.MAX_FRAGMENT_UNIFORM_VECTORS),S=s.getParameter(s.MAX_SAMPLES),T=s.getParameter(s.SAMPLES);return{isWebGL2:!0,getMaxAnisotropy:r,getMaxPrecision:c,textureFormatReadable:o,textureTypeReadable:a,precision:l,logarithmicDepthBuffer:u,reversedDepthBuffer:f,maxTextures:d,maxVertexTextures:g,maxTextureSize:v,maxCubemapSize:m,maxAttributes:p,maxVertexUniforms:x,maxVaryings:M,maxFragmentUniforms:y,maxSamples:S,samples:T}}function Px(s){let t=this,e=null,n=0,i=!1,r=!1,o=new $e,a=new Ft,c={value:null,needsUpdate:!1};this.uniform=c,this.numPlanes=0,this.numIntersection=0,this.init=function(f,u){let d=f.length!==0||u||n!==0||i;return i=u,n=f.length,d},this.beginShadows=function(){r=!0,h(null)},this.endShadows=function(){r=!1},this.setGlobalState=function(f,u){e=h(f,u,0)},this.setState=function(f,u,d){let g=f.clippingPlanes,v=f.clipIntersection,m=f.clipShadows,p=s.get(f);if(!i||g===null||g.length===0||r&&!m)r?h(null):l();else{let x=r?0:n,M=x*4,y=p.clippingState||null;c.value=y,y=h(g,u,M,d);for(let S=0;S!==M;++S)y[S]=e[S];p.clippingState=y,this.numIntersection=v?this.numPlanes:0,this.numPlanes+=x}};function l(){c.value!==e&&(c.value=e,c.needsUpdate=n>0),t.numPlanes=n,t.numIntersection=0}function h(f,u,d,g){let v=f!==null?f.length:0,m=null;if(v!==0){if(m=c.value,g!==!0||m===null){let p=d+v*4,x=u.matrixWorldInverse;a.getNormalMatrix(x),(m===null||m.length<p)&&(m=new Float32Array(p));for(let M=0,y=d;M!==v;++M,y+=4)o.copy(f[M]).applyMatrix4(x,a),o.normal.toArray(m,y),m[y+3]=o.constant}c.value=m,c.needsUpdate=!0}return t.numPlanes=v,t.numIntersection=0,m}}var Ps=class extends je{constructor(t=1,e={}){super(t,t,e),this.isWebGLCubeRenderTarget=!0;let n={width:t,height:t,depth:1},i=[n,n,n,n,n,n];this.texture=new mo(i),this._setTextureOptions(e),this.texture.isRenderTargetTexture=!0}fromEquirectangularTexture(t,e){this.texture.type=e.type,this.texture.colorSpace=e.colorSpace,this.texture.generateMipmaps=e.generateMipmaps,this.texture.minFilter=e.minFilter,this.texture.magFilter=e.magFilter;let n={uniforms:{tEquirect:{value:null}},vertexShader:`

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			`,fragmentShader:`

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			`},i=new dr(5,5,5),r=new ei({name:"CubemapFromEquirect",uniforms:Cs(n.uniforms),vertexShader:n.vertexShader,fragmentShader:n.fragmentShader,side:Ne,blending:Ts});r.uniforms.tEquirect.value=e;let o=new Ee(i,r),a=e.minFilter;return e.minFilter===Sn&&(e.minFilter=we),new Ji(1,10,this).update(t,o),e.minFilter=a,o.geometry.dispose(),o.material.dispose(),this}clear(t,e=!0,n=!0,i=!0){let r=t.getRenderTarget();for(let o=0;o<6;o++)t.setRenderTarget(this,o),t.clear(e,n,i);t.setRenderTarget(r)}},ep=256,Ix=3,Lx=20,Tp=256,wp=16,Nx=3,Dx=new R,Ux=new Pt,Is=class s{constructor(t){this._renderer=t,this._cubeSize=0,this._sourceTarget=null,this._cubeCamera=new Ji(1,10,null),this._boxMesh=new Ee(new dr(5,5,5),null),this._cubemapMaterial=null,this._equirectMaterial=null,this._blurMaterial=null,this._ggxMaterial=null,this._integrationMaterial=null}fromScene(t,e=0,n=.1,i=100,r={}){let{size:o=256,position:a=Dx}=r,c=this._renderer;this._setSize(o);let l=this._allocateTarget(),h=this._getSourceTarget(!0);e>0&&(h.texture.mipmapsAutoUpdate=!1);let f=c.autoClear,u=c.autoClearColor,d=c.autoClearDepth,g=c.autoClearStencil,v=t.background;c.autoClear=!0,c.autoClearColor=!0,c.autoClearDepth=!0,c.autoClearStencil=!0,v===null&&(t.background=c.getClearColor(Ux));let m=new Ji(n,i,h);return m.position.copy(a),m.update(c,t),c.autoClear=f,c.autoClearColor=u,c.autoClearDepth=d,c.autoClearStencil=g,t.background=v,e>0&&(h.texture.mipmapsAutoUpdate=!0,this._blur(l,e)),this._applyPMREM(l),l}fromEquirectangular(t,e=null){return this._fromTexture(t,e)}fromCubemap(t,e=null){return this._fromTexture(t,e)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=sp(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=ip(),this._compileMaterial(this._equirectMaterial))}dispose(){this._sourceTarget!==null&&this._sourceTarget.dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose(),this._blurMaterial!==null&&this._blurMaterial.dispose(),this._ggxMaterial!==null&&this._ggxMaterial.dispose(),this._integrationMaterial!==null&&this._integrationMaterial.dispose(),this._boxMesh.geometry.dispose()}static lodToRoughness(t,e){return e>0?1-Math.sqrt(1-t/e):0}_setSize(t){this._cubeSize=Math.max(ep,Vh(t))}_fromTexture(t,e){t.mapping===As||t.mapping===Mr?this._setSize(t.image.length===0?ep:t.image[0].width||t.image[0].image.width):this._setSize(t.image.width/4);let n=e||this._allocateTarget();return this._textureToCubemap(t),this._applyPMREM(n),n}_allocateTarget(){let t=this._cubeSize,e=np(t,!1,!1),n=Math.log2(t)-Ix;for(let i=0;i<=n;i++)e.texture.mipmaps.push({width:t>>i,height:t>>i});return e.texture.name="PMREM",e.texture.isPMREMTexture=!0,e}_getSourceTarget(t=!1){let e=this._cubeSize,n=this._sourceTarget;return(n===null||n.width!==e||t&&n.depthBuffer===!1)&&(n!==null&&n.dispose(),this._sourceTarget=np(e,!0,t)),this._sourceTarget}_compileMaterial(t){this._boxMesh.material=t,this._renderer.compile(this._boxMesh,this._cubeCamera.children[0])}_renderCube(t,e,n){let i=this._boxMesh,r=this._cubeCamera;i.material=n,r.renderTarget=t,r.activeMipmapLevel=e;let o=t.width>>e;t.viewport.set(0,0,o,o),r.update(this._renderer,i),t.viewport.set(0,0,t.width,t.height)}_textureToCubemap(t){let e;t.mapping===As||t.mapping===Mr?(this._cubemapMaterial===null&&(this._cubemapMaterial=sp()),e=this._cubemapMaterial,e.uniforms.flipEnvMap.value=t.isRenderTargetTexture===!1?-1:1):(this._equirectMaterial===null&&(this._equirectMaterial=ip()),e=this._equirectMaterial),e.uniforms.envMap.value=t,this._renderCube(this._getSourceTarget(),0,e)}_applyPMREM(t){this._ggxMaterial===null&&(this._ggxMaterial=Fx(),this._integrationMaterial=Ox());let e=this._cubeSize,n=t.texture.mipmaps.length-1,i=this._ggxMaterial.uniforms;i.envMap.value=this._sourceTarget.texture;let r=this._integrationMaterial.uniforms;r.envMap.value=this._sourceTarget.texture,r.sourceLod.value=Math.log2(e/wp);for(let o=0;o<=n;o++){let a=s.lodToRoughness(o,n);if(o>n-Nx)r.roughness.value=a,this._renderCube(t,o,this._integrationMaterial);else{let c=a>0?Math.log2(e)+.5*Math.log2(6/(Tp*Math.pow(a,4)))+.5:0;i.roughness.value=a,i.lodBias.value=c,this._renderCube(t,o,this._ggxMaterial)}}}_blur(t,e){this._blurMaterial===null&&(this._blurMaterial=Bx());let n=this._blurMaterial,i=n.uniforms,r=this._sourceTarget;i.sigma.value=Math.min(e,Math.PI)/Math.SQRT2,i.envMap.value=r.texture,this._renderCube(t,0,n),i.envMap.value=t.texture,this._renderCube(r,0,n)}};function np(s,t,e){return new Ps(s,{minFilter:Sn,generateMipmaps:t,type:cn,colorSpace:Ke,depthBuffer:e})}function Go(s,t,e){return new ei({name:s,uniforms:t,vertexShader:Nt.cube_vert,fragmentShader:e,side:Ne,blending:Ts,depthTest:!1,depthWrite:!1})}function Fx(){return Go("PMREMGGXConvolution",{envMap:{value:null},roughness:{value:0},lodBias:{value:0}},`

		#define GGX_SAMPLES ${Tp}u

		varying vec3 vWorldDirection;

		uniform samplerCube envMap;
		uniform float roughness;
		uniform float lodBias;

		#include <common>

		// Van der Corput radical inverse
		float radicalInverse_VdC( uint bits ) {

			bits = ( bits << 16u ) | ( bits >> 16u );
			bits = ( ( bits & 0x55555555u ) << 1u ) | ( ( bits & 0xAAAAAAAAu ) >> 1u );
			bits = ( ( bits & 0x33333333u ) << 2u ) | ( ( bits & 0xCCCCCCCCu ) >> 2u );
			bits = ( ( bits & 0x0F0F0F0Fu ) << 4u ) | ( ( bits & 0xF0F0F0F0u ) >> 4u );
			bits = ( ( bits & 0x00FF00FFu ) << 8u ) | ( ( bits & 0xFF00FF00u ) >> 8u );
			return float( bits ) * 2.3283064365386963e-10; // / 0x100000000

		}

		// Hammersley sequence
		vec2 hammersley( uint i, uint N ) {

			return vec2( float( i ) / float( N ), radicalInverse_VdC( i ) );

		}

		void main() {

			vec3 N = normalize( vWorldDirection );

			// For very low roughness, just sample the environment directly
			if ( roughness < 0.001 ) {

				gl_FragColor = vec4( textureLod( envMap, N, 0.0 ).rgb, 1.0 );
				return;

			}

			float alpha = roughness * roughness;
			float alpha2 = alpha * alpha;

			// Tangent space basis for VNDF sampling
			vec3 up = abs( N.z ) < 0.999 ? vec3( 0.0, 0.0, 1.0 ) : vec3( 1.0, 0.0, 0.0 );
			vec3 tangent = normalize( cross( up, N ) );
			vec3 bitangent = cross( N, tangent );

			vec3 prefilteredColor = vec3( 0.0 );
			float totalWeight = 0.0;

			for ( uint i = 0u; i < GGX_SAMPLES; i ++ ) {

				vec2 Xi = hammersley( i, GGX_SAMPLES );

				// With V = N, sample the reflected direction directly.
				float invQ = 1.0 / ( 1.0 - Xi.x + alpha2 * Xi.x );
				float NdotL = ( 1.0 - Xi.x - alpha2 * Xi.x ) * invQ;

				if ( NdotL > 0.0 ) {

					float phi = 2.0 * PI * Xi.y;
					float sinTheta = 2.0 * alpha * sqrt( Xi.x * ( 1.0 - Xi.x ) ) * invQ;
					vec3 L = N * NdotL + ( tangent * cos( phi ) + bitangent * sin( phi ) ) * sinTheta;

					// Match the source mip to the sample's solid angle. The terms
					// independent of the sample are precomputed in lodBias.
					float d = alpha2 * invQ;
					float lod = max( log2( d ) + lodBias, 0.0 );

					// Weight by NdotL for the split-sum approximation
					prefilteredColor += textureLod( envMap, L, lod ).rgb * NdotL;
					totalWeight += NdotL;

				}

			}

			gl_FragColor = vec4( prefilteredColor / totalWeight, 1.0 );

		}
	`)}function Ox(){return Go("PMREMGGXIntegration",{envMap:{value:null},roughness:{value:0},sourceLod:{value:0},sourceSize:{value:wp}},`

		varying vec3 vWorldDirection;

		uniform samplerCube envMap;
		uniform float roughness;
		uniform float sourceLod;
		uniform int sourceSize;

		void main() {

			vec3 N = normalize( vWorldDirection );

			float alpha = roughness * roughness;
			float alpha2 = alpha * alpha;

			float texelSize = 2.0 / float( sourceSize );

			vec3 prefilteredColor = vec3( 0.0 );
			float totalWeight = 0.0;

			// Pair opposite texels: only the one in N's hemisphere contributes.
			for ( int face = 0; face < 3; face ++ ) {

				for ( int y = 0; y < sourceSize; y ++ ) {

					for ( int x = 0; x < sourceSize; x ++ ) {

						vec2 uv = ( vec2( x, y ) + 0.5 ) * texelSize - 1.0;
						vec3 texelDirection = face == 0 ? vec3( 1.0, uv ) : ( face == 1 ? vec3( uv.x, 1.0, uv.y ) : vec3( uv, 1.0 ) );

						float invDistance = inversesqrt( 1.0 + dot( uv, uv ) );
						float NdotL = dot( N, texelDirection );
						texelDirection *= NdotL < 0.0 ? - 1.0 : 1.0;
						NdotL = abs( NdotL ) * invDistance;

						// With V = N, NdotH squared is ( 1 + NdotL ) / 2. Common factors
						// in the GGX distribution and texel solid angle cancel when normalized.
						float d = 1.0 + alpha2 + ( alpha2 - 1.0 ) * NdotL;
						float weight = NdotL * invDistance * invDistance * invDistance / ( d * d );

						prefilteredColor += textureLod( envMap, texelDirection, sourceLod ).rgb * weight;
						totalWeight += weight;

					}

				}

			}

			gl_FragColor = vec4( prefilteredColor / totalWeight, 1.0 );

		}
	`)}function Bx(){return Go("PMREMSphericalGaussianBlur",{envMap:{value:null},sigma:{value:0}},`

		#define SAMPLES ${Lx}
		#define GOLDEN_ANGLE 2.39996322973

		varying vec3 vWorldDirection;

		uniform samplerCube envMap;
		uniform float sigma;

		#include <common>

		void main() {

			vec3 outputDirection = normalize( vWorldDirection );

			vec3 up = abs( outputDirection.z ) < 0.999 ? vec3( 0.0, 0.0, 1.0 ) : vec3( 1.0, 0.0, 0.0 );
			vec3 tangent = normalize( cross( up, outputDirection ) );
			vec3 bitangent = cross( outputDirection, tangent );

			// Truncate the kernel at three standard deviations or at the antipode.
			float thetaMax = min( 3.0 * sigma, PI );
			float truncation = 1.0 - exp( - 0.5 * thetaMax * thetaMax / ( sigma * sigma ) );

			vec3 accumColor = vec3( 0.0 );
			float accumWeight = 0.0;

			for ( int i = 0; i < SAMPLES; i ++ ) {

				// Stratified inverse-CDF sampling of the Gaussian, placed on a golden-angle spiral.
				float stratum = ( float( i ) + 0.5 ) / float( SAMPLES );
				float theta = sigma * sqrt( - 2.0 * log( 1.0 - stratum * truncation ) );
				float phi = float( i ) * GOLDEN_ANGLE;

				vec3 offset = cos( phi ) * tangent + sin( phi ) * bitangent;
				vec3 sampleDirection = cos( theta ) * outputDirection + sin( theta ) * offset;

				// Correct the planar sample density to solid angle.
				float weight = sin( theta ) / theta;

				accumColor += weight * textureLod( envMap, sampleDirection, 0.0 ).rgb;
				accumWeight += weight;

			}

			gl_FragColor = vec4( accumColor / accumWeight, 1.0 );

		}
	`)}function ip(){return Go("PMREMEquirectangularToCubemap",{envMap:{value:null}},`

		varying vec3 vWorldDirection;

		uniform sampler2D envMap;

		#include <common>

		void main() {

			// Average four subpixel samples to preserve small, bright features.
			vec3 direction = normalize( vWorldDirection );
			vec3 dx = dFdx( direction ) * 0.25;
			vec3 dy = dFdy( direction ) * 0.25;

			vec3 color = textureLod( envMap, equirectUv( normalize( direction - dx - dy ) ), 0.0 ).rgb;
			color += textureLod( envMap, equirectUv( normalize( direction + dx - dy ) ), 0.0 ).rgb;
			color += textureLod( envMap, equirectUv( normalize( direction - dx + dy ) ), 0.0 ).rgb;
			color += textureLod( envMap, equirectUv( normalize( direction + dx + dy ) ), 0.0 ).rgb;
			gl_FragColor = vec4( color * 0.25, 1.0 );

		}
	`)}function sp(){return Go("PMREMCubemapToCubemap",{envMap:{value:null},flipEnvMap:{value:-1}},`

		varying vec3 vWorldDirection;

		uniform samplerCube envMap;
		uniform float flipEnvMap;

		void main() {

			gl_FragColor = vec4( textureCube( envMap, vec3( flipEnvMap * vWorldDirection.x, vWorldDirection.yz ) ).rgb, 1.0 );

		}
	`)}function zx(s){let t=new WeakMap,e=new WeakMap,n=null;function i(u,d=!1){return u==null?null:d?o(u):r(u)}function r(u){if(u&&u.isTexture){let d=u.mapping;if(d===Sr||d===ic)if(t.has(u)){let g=t.get(u).texture;return a(g,u.mapping)}else{let g=u.image;if(g&&g.height>0){let v=new Ps(g.height);return v.fromEquirectangularTexture(s,u),t.set(u,v),u.addEventListener("dispose",l),a(v.texture,u.mapping)}else return null}}return u}function o(u){if(u&&u.isTexture&&u.isPMREMTexture!==!0){let d=u.mapping,g=d===Sr||d===ic,v=d===As||d===Mr;if(g||v){let m=e.get(u),p=m!==void 0?m.texture.pmremVersion:0;if(u.isRenderTargetTexture&&u.pmremVersion!==p)return n===null&&(n=new Is(s)),m=g?n.fromEquirectangular(u,m):n.fromCubemap(u,m),m.texture.pmremVersion=u.pmremVersion,e.set(u,m),m.texture;if(m!==void 0)return m.texture;{let x=u.image;return g&&x&&x.height>0||v&&x&&c(x)?(n===null&&(n=new Is(s)),m=g?n.fromEquirectangular(u):n.fromCubemap(u),m.texture.pmremVersion=u.pmremVersion,e.set(u,m),u.addEventListener("dispose",h),m.texture):null}}}return u}function a(u,d){return d===Sr?u.mapping=As:d===ic&&(u.mapping=Mr),u}function c(u){let d=0,g=6;for(let v=0;v<g;v++)u[v]!==void 0&&d++;return d===g}function l(u){let d=u.target;d.removeEventListener("dispose",l);let g=t.get(d);g!==void 0&&(t.delete(d),g.dispose())}function h(u){let d=u.target;d.removeEventListener("dispose",h);let g=e.get(d);g!==void 0&&(e.delete(d),g.dispose())}function f(){t=new WeakMap,e=new WeakMap,n!==null&&(n.dispose(),n=null)}return{get:i,dispose:f}}function kx(s){let t={};function e(n){if(t[n]!==void 0)return t[n];let i=s.getExtension(n);return t[n]=i,i}return{has:function(n){return e(n)!==null},init:function(){e("EXT_color_buffer_float"),e("WEBGL_clip_cull_distance"),e("OES_texture_float_linear"),e("EXT_color_buffer_half_float"),e("WEBGL_multisampled_render_to_texture"),e("WEBGL_render_shared_exponent")},get:function(n){let i=e(n);return i===null&&ps("WebGLRenderer: "+n+" extension not supported."),i}}}function Vx(s,t,e,n){let i={},r=new WeakMap,o=new FinalizationRegistry(g=>delete i[g]);function a(g){c(g.target)}function c(g){g.index!==null&&t.remove(g.index);for(let m in g.attributes)t.remove(g.attributes[m]);g.removeEventListener("dispose",a),delete i[g.id],o.unregister(g);let v=r.get(g);v&&(t.remove(v),r.delete(g)),n.releaseStatesOfGeometry(g),g.isInstancedBufferGeometry===!0&&delete g._maxInstanceCount,e.memory.geometries--}function l(g,v){return i[v.id]!==void 0||(v.addEventListener("dispose",a),i[v.id]=new WeakRef(v),o.register(v,v.id,v),e.memory.geometries++),v}function h(g){let v=g.attributes;for(let m in v)t.update(v[m],s.ARRAY_BUFFER)}function f(g){let v=g.index,m=g.attributes.position,p=0;if(m===void 0)return;let x=v!==null?v.array.length:m.array.length/3-1,M=m.count>=65535?co:ao,y=new M(Math.ceil(x/3)*6,1),S=y.array;if(v!==null){let _=v.array;p=v.version;for(let b=0,I=0;b<x;b+=3){let E=_[b+0],L=_[b+1],C=_[b+2];S[I++]=E,S[I++]=L,S[I++]=L,S[I++]=C,S[I++]=C,S[I++]=E}}else{p=m.version;for(let _=0,b=0;_<x;_+=3){let I=_+0,E=_+1,L=_+2;S[b++]=I,S[b++]=E,S[b++]=E,S[b++]=L,S[b++]=L,S[b++]=I}}y.version=p;let T=r.get(g);T&&t.remove(T),r.set(g,y)}function u(g){let v=r.get(g);if(v){let m=g.index;m!==null&&v.version<m.version&&f(g)}else f(g);return r.get(g)}function d(){for(let g in i){let v=i[g].deref();v!==void 0&&c(v)}}return{get:l,update:h,getWireframeAttribute:u,dispose:d}}function Gx(s,t,e){let n;function i(f){n=f}let r,o;function a(f){r=f.type,o=f.bytesPerElement}function c(f,u){s.drawElements(n,u,r,f*o),e.update(u,n,1)}function l(f,u,d){d!==0&&(s.drawElementsInstanced(n,u,r,f*o,d),e.update(u,n,d))}function h(f,u,d){if(d===0)return;t.get("WEBGL_multi_draw").multiDrawElementsWEBGL(n,u,0,r,f,0,d);let v=0;for(let m=0;m<d;m++)v+=u[m];e.update(v,n,1)}this.setMode=i,this.setIndex=a,this.render=c,this.renderInstances=l,this.renderMultiDraw=h}function Hx(s){let t={geometries:0,textures:0},e={frame:0,calls:0,triangles:0,points:0,lines:0};function n(r,o,a){switch(e.calls++,o){case s.TRIANGLES:e.triangles+=a*(r/3);break;case s.LINES:e.lines+=a*(r/2);break;case s.LINE_STRIP:e.lines+=a*(r-1);break;case s.LINE_LOOP:e.lines+=a*r;break;case s.POINTS:e.points+=a*r;break;default:Dt("WebGLInfo: Unknown draw mode:",o);break}}function i(){e.calls=0,e.triangles=0,e.points=0,e.lines=0}return{memory:t,render:e,programs:null,autoReset:!0,reset:i,update:n}}function Wx(s,t,e){let n=new WeakMap,i=new Zt;function r(o,a,c){let l=o.morphTargetInfluences,h=a.morphAttributes.position||a.morphAttributes.normal||a.morphAttributes.color,f=h!==void 0?h.length:0,u=n.get(a);if(u===void 0||u.count!==f){let I=function(){_.dispose(),n.delete(a),a.removeEventListener("dispose",I)};u!==void 0&&u.texture.dispose();let d=a.morphAttributes.position!==void 0,g=a.morphAttributes.normal!==void 0,v=a.morphAttributes.color!==void 0,m=a.morphAttributes.position||[],p=a.morphAttributes.normal||[],x=a.morphAttributes.color||[],M=0;d===!0&&(M=1),g===!0&&(M=2),v===!0&&(M=3);let y=a.attributes.position.count*M,S=1;y>t.maxTextureSize&&(S=Math.ceil(y/t.maxTextureSize),y=t.maxTextureSize);let T=new Float32Array(y*S*4*f),_=new so(T,y,S,f);_.type=An,_.needsUpdate=!0;let b=M*4;for(let E=0;E<f;E++){let L=m[E],C=p[E],U=x[E],N=y*S*4*E;for(let B=0;B<L.count;B++){let G=B*b;d===!0&&(i.fromBufferAttribute(L,B),T[N+G+0]=i.x,T[N+G+1]=i.y,T[N+G+2]=i.z,T[N+G+3]=0),g===!0&&(i.fromBufferAttribute(C,B),T[N+G+4]=i.x,T[N+G+5]=i.y,T[N+G+6]=i.z,T[N+G+7]=0),v===!0&&(i.fromBufferAttribute(U,B),T[N+G+8]=i.x,T[N+G+9]=i.y,T[N+G+10]=i.z,T[N+G+11]=U.itemSize===4?i.w:1)}}u={count:f,texture:_,size:new At(y,S)},n.set(a,u),a.addEventListener("dispose",I)}if(o.isInstancedMesh===!0&&o.morphTexture!==null)c.getUniforms().setValue(s,"morphTexture",o.morphTexture,e);else{let d=0;for(let v=0;v<l.length;v++)d+=l[v];let g=a.morphTargetsRelative?1:1-d;c.getUniforms().setValue(s,"morphTargetBaseInfluence",g),c.getUniforms().setValue(s,"morphTargetInfluences",l)}c.getUniforms().setValue(s,"morphTargetsTexture",u.texture,e),c.getUniforms().setValue(s,"morphTargetsTextureSize",u.size)}return{update:r}}function Xx(s,t,e,n,i){let r=new WeakMap;function o(l){let h=i.render.frame,f=l.geometry,u=t.get(l,f);if(r.get(u)!==h&&(t.update(u),r.set(u,h)),l.isInstancedMesh&&(l.hasEventListener("dispose",c)===!1&&l.addEventListener("dispose",c),r.get(l)!==h&&(e.update(l.instanceMatrix,s.ARRAY_BUFFER),l.instanceColor!==null&&e.update(l.instanceColor,s.ARRAY_BUFFER),r.set(l,h))),l.isSkinnedMesh){let d=l.skeleton;r.get(d)!==h&&(d.update(),r.set(d,h))}return u}function a(){r=new WeakMap}function c(l){let h=l.target;h.removeEventListener("dispose",c),n.releaseStatesOfObject(h),e.remove(h.instanceMatrix),h.instanceColor!==null&&e.remove(h.instanceColor)}return{update:o,dispose:a}}var qx={[Co]:"LINEAR_TONE_MAPPING",[Po]:"REINHARD_TONE_MAPPING",[Io]:"CINEON_TONE_MAPPING",[vr]:"ACES_FILMIC_TONE_MAPPING",[Lo]:"AGX_TONE_MAPPING",[Ah]:"NEUTRAL_TONE_MAPPING",[wh]:"CUSTOM_TONE_MAPPING"};function Yx(s,t,e,n,i,r){let o=new je(t,e,{type:s,depthBuffer:i,stencilBuffer:r,samples:n?4:0,storeMultisampledDepthBuffer:!1,storeMultisampledStencilBuffer:!1,resolveDepthBuffer:!1,resolveStencilBuffer:!1}),a=null,c=null,l=null,h=new ye;h.setAttribute("position",new ae([-1,3,0,-1,-1,0,3,-1,0],3)),h.setAttribute("uv",new ae([0,2,0,0,2,0],2));let f=new qa({uniforms:{tDiffuse:{value:null}},vertexShader:`
			precision highp float;

			uniform mat4 modelViewMatrix;
			uniform mat4 projectionMatrix;

			attribute vec3 position;
			attribute vec2 uv;

			varying vec2 vUv;

			void main() {
				vUv = uv;
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}`,fragmentShader:`
			precision highp float;

			uniform sampler2D tDiffuse;

			varying vec2 vUv;

			#include <tonemapping_pars_fragment>
			#include <colorspace_pars_fragment>

			void main() {
				gl_FragColor = texture2D( tDiffuse, vUv );

				#ifdef LINEAR_TONE_MAPPING
					gl_FragColor.rgb = LinearToneMapping( gl_FragColor.rgb );
				#elif defined( REINHARD_TONE_MAPPING )
					gl_FragColor.rgb = ReinhardToneMapping( gl_FragColor.rgb );
				#elif defined( CINEON_TONE_MAPPING )
					gl_FragColor.rgb = CineonToneMapping( gl_FragColor.rgb );
				#elif defined( ACES_FILMIC_TONE_MAPPING )
					gl_FragColor.rgb = ACESFilmicToneMapping( gl_FragColor.rgb );
				#elif defined( AGX_TONE_MAPPING )
					gl_FragColor.rgb = AgXToneMapping( gl_FragColor.rgb );
				#elif defined( NEUTRAL_TONE_MAPPING )
					gl_FragColor.rgb = NeutralToneMapping( gl_FragColor.rgb );
				#elif defined( CUSTOM_TONE_MAPPING )
					gl_FragColor.rgb = CustomToneMapping( gl_FragColor.rgb );
				#endif

				#ifdef SRGB_TRANSFER
					gl_FragColor = sRGBTransferOETF( gl_FragColor );
				#endif
			}`,depthTest:!1,depthWrite:!1}),u=new Ee(h,f),d=new qn(-1,1,1,-1,0,1),g=null,v=null,m=!1,p,x=null,M=[],y=!1;this.setSize=function(S,T){o.setSize(S,T),a!==null&&a.setSize(S,T),c!==null&&c.setSize(S,T);for(let _=0;_<M.length;_++){let b=M[_];b.setSize&&b.setSize(S,T)}},this.setEffects=function(S){M=S,y=M.length>0&&M[0].isRenderPass===!0;let T=o.width,_=o.height;M.length>0&&a===null&&(a=new je(T,_,{type:cn,depthBuffer:!1,stencilBuffer:!1}),c=new je(T,_,{type:cn,depthBuffer:!1,stencilBuffer:!1}));let b=i===!0&&M.some(I=>I.needsDepthTexture===!0);b!==(o.depthTexture!==null)&&(b===!0&&l===null&&(l=new Ei(T,_),r===!0&&(l.format=Di,l.type=Rs)),o.dispose(),o.depthTexture=b?l:null,o.resolveDepthBuffer=b,o.storeMultisampledDepthBuffer=b);for(let I=0;I<M.length;I++){let E=M[I];E.setSize&&E.setSize(T,_),b&&E.needsDepthTexture===!0&&E.setDepthTexture&&E.setDepthTexture(l)}},this.begin=function(S,T){if(m||S.toneMapping===ri&&M.length===0)return!1;if(x=T,T!==null){let _=T.width,b=T.height;(o.width!==_||o.height!==b)&&this.setSize(_,b)}return y===!1&&S.setRenderTarget(o),p=S.toneMapping,S.toneMapping=ri,!0},this.hasRenderPass=function(){return y},this.end=function(S,T){S.toneMapping=p,m=!0;let _=o,b=a;for(let I=0;I<M.length;I++){let E=M[I];E.enabled!==!1&&(E.render(S,b,_,T),E.needsSwap!==!1&&(_=b,b=b===a?c:a))}if(g!==S.outputColorSpace||v!==S.toneMapping){g=S.outputColorSpace,v=S.toneMapping,f.defines={},Ht.getTransfer(g)===se&&(f.defines.SRGB_TRANSFER="");let I=qx[v];I&&(f.defines[I]=""),f.needsUpdate=!0}f.uniforms.tDiffuse.value=_.texture,S.setRenderTarget(x),S.render(u,d),x=null,m=!1},this.isCompositing=function(){return m},this.dispose=function(){o.dispose(),a!==null&&a.dispose(),c!==null&&c.dispose(),h.dispose(),f.dispose()}}var Ap=new ke,Ep=new Ei(1,1),Rp=new go(1),Cp=new so,Pp=new Ga,Ip=new mo,rp=[],op=[],ap=new Float32Array(16),cp=new Float32Array(9),lp=new Float32Array(4);function Er(s,t,e){let n=s[0];if(n<=0||n>0)return s;let i=t*e,r=rp[i];if(r===void 0&&(r=new Float32Array(i),rp[i]=r),t!==0){n.toArray(r,0);for(let o=1,a=0;o!==t;++o)a+=e,s[o].toArray(r,a)}return r}function Ve(s,t){if(s.length!==t.length)return!1;for(let e=0,n=s.length;e<n;e++)if(s[e]!==t[e])return!1;return!0}function Ge(s,t){for(let e=0,n=t.length;e<n;e++)s[e]=t[e]}function Kc(s,t){let e=op[t];e===void 0&&(e=new Int32Array(t),op[t]=e);for(let n=0;n!==t;++n)e[n]=s.allocateTextureUnit();return e}function Kx(s,t){let e=this.cache;e[0]!==t&&(s.uniform1f(this.addr,t),e[0]=t)}function Zx(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(s.uniform2f(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(Ve(e,t))return;s.uniform2fv(this.addr,t),Ge(e,t)}}function Jx(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(s.uniform3f(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else if(t.r!==void 0)(e[0]!==t.r||e[1]!==t.g||e[2]!==t.b)&&(s.uniform3f(this.addr,t.r,t.g,t.b),e[0]=t.r,e[1]=t.g,e[2]=t.b);else{if(Ve(e,t))return;s.uniform3fv(this.addr,t),Ge(e,t)}}function $x(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(s.uniform4f(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(Ve(e,t))return;s.uniform4fv(this.addr,t),Ge(e,t)}}function jx(s,t){let e=this.cache,n=t.elements;if(n===void 0){if(Ve(e,t))return;s.uniformMatrix2fv(this.addr,!1,t),Ge(e,t)}else{if(Ve(e,n))return;lp.set(n),s.uniformMatrix2fv(this.addr,!1,lp),Ge(e,n)}}function Qx(s,t){let e=this.cache,n=t.elements;if(n===void 0){if(Ve(e,t))return;s.uniformMatrix3fv(this.addr,!1,t),Ge(e,t)}else{if(Ve(e,n))return;cp.set(n),s.uniformMatrix3fv(this.addr,!1,cp),Ge(e,n)}}function ty(s,t){let e=this.cache,n=t.elements;if(n===void 0){if(Ve(e,t))return;s.uniformMatrix4fv(this.addr,!1,t),Ge(e,t)}else{if(Ve(e,n))return;ap.set(n),s.uniformMatrix4fv(this.addr,!1,ap),Ge(e,n)}}function ey(s,t){let e=this.cache;e[0]!==t&&(s.uniform1i(this.addr,t),e[0]=t)}function ny(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(s.uniform2i(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(Ve(e,t))return;s.uniform2iv(this.addr,t),Ge(e,t)}}function iy(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(s.uniform3i(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(Ve(e,t))return;s.uniform3iv(this.addr,t),Ge(e,t)}}function sy(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(s.uniform4i(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(Ve(e,t))return;s.uniform4iv(this.addr,t),Ge(e,t)}}function ry(s,t){let e=this.cache;e[0]!==t&&(s.uniform1ui(this.addr,t),e[0]=t)}function oy(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(s.uniform2ui(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(Ve(e,t))return;s.uniform2uiv(this.addr,t),Ge(e,t)}}function ay(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(s.uniform3ui(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(Ve(e,t))return;s.uniform3uiv(this.addr,t),Ge(e,t)}}function cy(s,t){let e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(s.uniform4ui(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(Ve(e,t))return;s.uniform4uiv(this.addr,t),Ge(e,t)}}function Zc(s){return s.version===0&&(s.compareFunction=Oh,s.needsUpdate=!0),s}function ly(s,t,e){let n=this.cache,i=e.allocateTextureUnit();n[0]!==i&&(s.uniform1i(this.addr,i),n[0]=i);let r;this.type===s.SAMPLER_2D_SHADOW?r=Zc(Ep):r=Ap,e.setTexture2D(t||r,i)}function hy(s,t,e){let n=this.cache,i=e.allocateTextureUnit();n[0]!==i&&(s.uniform1i(this.addr,i),n[0]=i),e.setTexture3D(t||Pp,i)}function uy(s,t,e){let n=this.cache,i=e.allocateTextureUnit();n[0]!==i&&(s.uniform1i(this.addr,i),n[0]=i);let r;this.type===s.SAMPLER_CUBE_SHADOW?r=Zc(Rp):r=Ip,e.setTextureCube(t||r,i)}function fy(s,t,e){let n=this.cache,i=e.allocateTextureUnit();n[0]!==i&&(s.uniform1i(this.addr,i),n[0]=i),e.setTexture2DArray(t||Cp,i)}function dy(s){switch(s){case 5126:return Kx;case 35664:return Zx;case 35665:return Jx;case 35666:return $x;case 35674:return jx;case 35675:return Qx;case 35676:return ty;case 5124:case 35670:return ey;case 35667:case 35671:return ny;case 35668:case 35672:return iy;case 35669:case 35673:return sy;case 5125:return ry;case 36294:return oy;case 36295:return ay;case 36296:return cy;case 35678:case 36198:case 36298:case 36306:case 35682:return ly;case 35679:case 36299:case 36307:return hy;case 35680:case 36300:case 36308:case 36293:return uy;case 36289:case 36303:case 36311:case 36292:return fy}}function py(s,t){s.uniform1fv(this.addr,t)}function my(s,t){let e=Er(t,this.size,2);s.uniform2fv(this.addr,e)}function gy(s,t){let e=Er(t,this.size,3);s.uniform3fv(this.addr,e)}function _y(s,t){let e=Er(t,this.size,4);s.uniform4fv(this.addr,e)}function xy(s,t){let e=Er(t,this.size,4);s.uniformMatrix2fv(this.addr,!1,e)}function yy(s,t){let e=Er(t,this.size,9);s.uniformMatrix3fv(this.addr,!1,e)}function vy(s,t){let e=Er(t,this.size,16);s.uniformMatrix4fv(this.addr,!1,e)}function My(s,t){s.uniform1iv(this.addr,t)}function Sy(s,t){s.uniform2iv(this.addr,t)}function by(s,t){s.uniform3iv(this.addr,t)}function Ty(s,t){s.uniform4iv(this.addr,t)}function wy(s,t){s.uniform1uiv(this.addr,t)}function Ay(s,t){s.uniform2uiv(this.addr,t)}function Ey(s,t){s.uniform3uiv(this.addr,t)}function Ry(s,t){s.uniform4uiv(this.addr,t)}function Cy(s,t,e){let n=this.cache,i=t.length,r=Kc(e,i);Ve(n,r)||(s.uniform1iv(this.addr,r),Ge(n,r));let o;this.type===s.SAMPLER_2D_SHADOW?o=Zc(Ep):o=Ap;for(let a=0;a!==i;++a)e.setTexture2D(t[a]||o,r[a])}function Py(s,t,e){let n=this.cache,i=t.length,r=Kc(e,i);Ve(n,r)||(s.uniform1iv(this.addr,r),Ge(n,r));for(let o=0;o!==i;++o)e.setTexture3D(t[o]||Pp,r[o])}function Iy(s,t,e){let n=this.cache,i=t.length,r=Kc(e,i);Ve(n,r)||(s.uniform1iv(this.addr,r),Ge(n,r));let o;this.type===s.SAMPLER_CUBE_SHADOW?o=Zc(Rp):o=Ip;for(let a=0;a!==i;++a)e.setTextureCube(t[a]||o,r[a])}function Ly(s,t,e){let n=this.cache,i=t.length,r=Kc(e,i);Ve(n,r)||(s.uniform1iv(this.addr,r),Ge(n,r));for(let o=0;o!==i;++o)e.setTexture2DArray(t[o]||Cp,r[o])}function Ny(s){switch(s){case 5126:return py;case 35664:return my;case 35665:return gy;case 35666:return _y;case 35674:return xy;case 35675:return yy;case 35676:return vy;case 5124:case 35670:return My;case 35667:case 35671:return Sy;case 35668:case 35672:return by;case 35669:case 35673:return Ty;case 5125:return wy;case 36294:return Ay;case 36295:return Ey;case 36296:return Ry;case 35678:case 36198:case 36298:case 36306:case 35682:return Cy;case 35679:case 36299:case 36307:return Py;case 35680:case 36300:case 36308:case 36293:return Iy;case 36289:case 36303:case 36311:case 36292:return Ly}}var eu=class{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.setValue=dy(e.type)}},nu=class{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.size=e.size,this.setValue=Ny(e.type)}},iu=class{constructor(t){this.id=t,this.seq=[],this.map={}}setValue(t,e,n){let i=this.seq;for(let r=0,o=i.length;r!==o;++r){let a=i[r];a.setValue(t,e[a.id],n)}}},Qh=/(\w+)(\])?(\[|\.)?/g;function hp(s,t){s.seq.push(t),s.map[t.id]=t}function Dy(s,t,e){let n=s.name,i=n.length;for(Qh.lastIndex=0;;){let r=Qh.exec(n),o=Qh.lastIndex,a=r[1],c=r[2]==="]",l=r[3];if(c&&(a=a|0),l===void 0||l==="["&&o+2===i){hp(e,l===void 0?new eu(a,s,t):new nu(a,s,t));break}else{let f=e.map[a];f===void 0&&(f=new iu(a),hp(e,f)),e=f}}}var Ar=class{constructor(t,e){this.seq=[],this.map={};let n=t.getProgramParameter(e,t.ACTIVE_UNIFORMS);for(let o=0;o<n;++o){let a=t.getActiveUniform(e,o),c=t.getUniformLocation(e,a.name);Dy(a,c,this)}let i=[],r=[];for(let o of this.seq)o.type===t.SAMPLER_2D_SHADOW||o.type===t.SAMPLER_CUBE_SHADOW||o.type===t.SAMPLER_2D_ARRAY_SHADOW?i.push(o):r.push(o);i.length>0&&(this.seq=i.concat(r))}setValue(t,e,n,i){let r=this.map[e];r!==void 0&&r.setValue(t,n,i)}setOptional(t,e,n){let i=e[n];i!==void 0&&this.setValue(t,n,i)}static upload(t,e,n,i){for(let r=0,o=e.length;r!==o;++r){let a=e[r],c=n[a.id];c.needsUpdate!==!1&&a.setValue(t,c.value,i)}}static seqWithValue(t,e){let n=[];for(let i=0,r=t.length;i!==r;++i){let o=t[i];o.id in e&&n.push(o)}return n}};function up(s,t,e){let n=s.createShader(t);return s.shaderSource(n,e),s.compileShader(n),n}var Uy=37297,Fy=0;function Oy(s,t){let e=s.split(`
`),n=[],i=Math.max(t-6,0),r=Math.min(t+6,e.length);for(let o=i;o<r;o++){let a=o+1;n.push(`${a===t?">":" "} ${a}: ${e[o]}`)}return n.join(`
`)}var fp=new Ft;function By(s){Ht._getMatrix(fp,Ht.workingColorSpace,s);let t=`mat3( ${fp.elements.map(e=>e.toFixed(4))} )`;switch(Ht.getTransfer(s)){case no:return[t,"LinearTransferOETF"];case se:return[t,"sRGBTransferOETF"];default:return Tt("WebGLProgram: Unsupported color space: ",s),[t,"LinearTransferOETF"]}}function dp(s,t,e){let n=s.getShaderParameter(t,s.COMPILE_STATUS),r=(s.getShaderInfoLog(t)||"").trim();if(n&&r==="")return"";let o=/ERROR: 0:(\d+)/.exec(r);if(o){let a=parseInt(o[1]);return e.toUpperCase()+`

`+r+`

`+Oy(s.getShaderSource(t),a)}else return r}function zy(s,t){let e=By(t);return[`vec4 ${s}( vec4 value ) {`,`	return ${e[1]}( vec4( ${e[0]} * value.rgb, value.a ) );`,"}"].join(`
`)}var ky={[Co]:"Linear",[Po]:"Reinhard",[Io]:"Cineon",[vr]:"ACESFilmic",[Lo]:"AgX",[Ah]:"Neutral",[wh]:"Custom"};function Vy(s,t){let e=ky[t];return e===void 0?(Tt("WebGLProgram: Unsupported toneMapping:",t),"vec3 "+s+"( vec3 color ) { return LinearToneMapping( color ); }"):"vec3 "+s+"( vec3 color ) { return "+e+"ToneMapping( color ); }"}var Xc=new R;function Gy(){Ht.getLuminanceCoefficients(Xc);let s=Xc.x.toFixed(4),t=Xc.y.toFixed(4),e=Xc.z.toFixed(4);return["float luminance( const in vec3 rgb ) {",`	const vec3 weights = vec3( ${s}, ${t}, ${e} );`,"	return dot( weights, rgb );","}"].join(`
`)}function Hy(s){return[s.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":"",s.extensionMultiDraw?"#extension GL_ANGLE_multi_draw : require":""].filter(Vo).join(`
`)}function Wy(s){let t=[];for(let e in s){let n=s[e];n!==!1&&t.push("#define "+e+" "+n)}return t.join(`
`)}function Xy(s,t){let e={},n=s.getProgramParameter(t,s.ACTIVE_ATTRIBUTES);for(let i=0;i<n;i++){let r=s.getActiveAttrib(t,i),o=r.name,a=1;r.type===s.FLOAT_MAT2&&(a=2),r.type===s.FLOAT_MAT3&&(a=3),r.type===s.FLOAT_MAT4&&(a=4),e[o]={type:r.type,location:s.getAttribLocation(t,o),locationSize:a}}return e}function Vo(s){return s!==""}function pp(s,t){let e=t.numSpotLightShadows+t.numSpotLightMaps-t.numSpotLightShadowsWithMaps;return s.replace(/NUM_SUN_LIGHTS/g,t.numSunLights).replace(/NUM_DIR_LIGHTS/g,t.numDirLights).replace(/NUM_SPOT_LIGHTS/g,t.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,t.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,e).replace(/NUM_RECT_AREA_LIGHTS/g,t.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,t.numPointLights).replace(/NUM_HEMI_LIGHTS/g,t.numHemiLights).replace(/NUM_SUN_LIGHT_SHADOWS/g,t.numSunLightShadows).replace(/NUM_DIR_LIGHT_SHADOWS/g,t.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,t.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,t.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,t.numPointLightShadows).replace(/NUM_LIGHT_PROBE_GRIDS/g,t.numLightProbeGrids)}function mp(s,t){return s.replace(/NUM_CLIPPING_PLANES/g,t.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,t.numClippingPlanes-t.numClipIntersection)}var qy=/^[ \t]*#include +<([\w\d./]+)>/gm;function su(s){return s.replace(qy,Yy)}function Yy(s,t){let e=Nt[t];if(e===void 0)throw new Error("THREE.WebGLProgram: Can not resolve #include <"+t+">");return su(e)}var Ky=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function gp(s){return s.replace(Ky,Zy)}function Zy(s,t,e,n){let i="";for(let r=parseInt(t);r<parseInt(e);r++)i+=n.replace(/\[\s*i\s*\]/g,"[ "+r+" ]").replace(/UNROLLED_LOOP_INDEX/g,r);return i}function _p(s){let t=`precision ${s.precision} float;
	precision ${s.precision} int;
	precision ${s.precision} sampler2D;
	precision ${s.precision} samplerCube;
	precision ${s.precision} sampler3D;
	precision ${s.precision} sampler2DArray;
	precision ${s.precision} sampler2DShadow;
	precision ${s.precision} samplerCubeShadow;
	precision ${s.precision} sampler2DArrayShadow;
	precision ${s.precision} isampler2D;
	precision ${s.precision} isampler3D;
	precision ${s.precision} isamplerCube;
	precision ${s.precision} isampler2DArray;
	precision ${s.precision} usampler2D;
	precision ${s.precision} usampler3D;
	precision ${s.precision} usamplerCube;
	precision ${s.precision} usampler2DArray;
	`;return s.precision==="highp"?t+=`
#define HIGH_PRECISION`:s.precision==="mediump"?t+=`
#define MEDIUM_PRECISION`:s.precision==="lowp"&&(t+=`
#define LOW_PRECISION`),t}var Jy={[Eo]:"SHADOWMAP_TYPE_PCF",[xr]:"SHADOWMAP_TYPE_VSM"};function $y(s){return Jy[s.shadowMapType]||"SHADOWMAP_TYPE_BASIC"}var jy={[Mr]:"ENVMAP_MODE_REFRACTION"};function Qy(s){return s.envMap===!1?"ENVMAP_MODE_REFLECTION":jy[s.envMapMode]||"ENVMAP_MODE_REFLECTION"}var tv={[Th]:"ENVMAP_BLENDING_MULTIPLY",[Ud]:"ENVMAP_BLENDING_MIX",[Fd]:"ENVMAP_BLENDING_ADD"};function ev(s){return s.envMap===!1?"ENVMAP_BLENDING_NONE":tv[s.combine]||"ENVMAP_BLENDING_NONE"}function nv(s,t,e,n){let i=s.getContext(),r=e.defines,o=e.vertexShader,a=e.fragmentShader,c=$y(e),l=e.envMapPMREM===!0?"ENVMAP_TYPE_PMREM":"ENVMAP_TYPE_CUBE",h=Qy(e),f=ev(e),u=Hy(e),d=Wy(r),g=i.createProgram(),v,m,p=e.glslVersion?"#version "+e.glslVersion+`
`:"";e.isRawShaderMaterial?(v=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,d].filter(Vo).join(`
`),v.length>0&&(v+=`
`),m=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,d].filter(Vo).join(`
`),m.length>0&&(m+=`
`)):(v=[_p(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,d,e.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",e.batching?"#define USE_BATCHING":"",e.batchingColor?"#define USE_BATCHING_COLOR":"",e.instancing?"#define USE_INSTANCING":"",e.instancingColor?"#define USE_INSTANCING_COLOR":"",e.instancingMorph?"#define USE_INSTANCING_MORPH":"",e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+h:"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.displacementMap?"#define USE_DISPLACEMENTMAP":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.diffuseRoughnessMap?"#define USE_DIFFUSE_ROUGHNESSMAP":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.mapUv?"#define MAP_UV "+e.mapUv:"",e.alphaMapUv?"#define ALPHAMAP_UV "+e.alphaMapUv:"",e.lightMapUv?"#define LIGHTMAP_UV "+e.lightMapUv:"",e.aoMapUv?"#define AOMAP_UV "+e.aoMapUv:"",e.emissiveMapUv?"#define EMISSIVEMAP_UV "+e.emissiveMapUv:"",e.bumpMapUv?"#define BUMPMAP_UV "+e.bumpMapUv:"",e.normalMapUv?"#define NORMALMAP_UV "+e.normalMapUv:"",e.displacementMapUv?"#define DISPLACEMENTMAP_UV "+e.displacementMapUv:"",e.metalnessMapUv?"#define METALNESSMAP_UV "+e.metalnessMapUv:"",e.roughnessMapUv?"#define ROUGHNESSMAP_UV "+e.roughnessMapUv:"",e.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+e.anisotropyMapUv:"",e.clearcoatMapUv?"#define CLEARCOATMAP_UV "+e.clearcoatMapUv:"",e.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+e.clearcoatNormalMapUv:"",e.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+e.clearcoatRoughnessMapUv:"",e.diffuseRoughnessMapUv?"#define DIFFUSE_ROUGHNESSMAP_UV "+e.diffuseRoughnessMapUv:"",e.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+e.iridescenceMapUv:"",e.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+e.iridescenceThicknessMapUv:"",e.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+e.sheenColorMapUv:"",e.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+e.sheenRoughnessMapUv:"",e.specularMapUv?"#define SPECULARMAP_UV "+e.specularMapUv:"",e.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+e.specularColorMapUv:"",e.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+e.specularIntensityMapUv:"",e.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+e.transmissionMapUv:"",e.thicknessMapUv?"#define THICKNESSMAP_UV "+e.thicknessMapUv:"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexNormals?"#define HAS_NORMAL":"",e.vertexColors?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.flatShading?"#define FLAT_SHADED":"",e.skinning?"#define USE_SKINNING":"",e.morphTargets?"#define USE_MORPHTARGETS":"",e.morphNormals&&e.flatShading===!1?"#define USE_MORPHNORMALS":"",e.morphColors?"#define USE_MORPHCOLORS":"",e.morphTargetsCount>0?"#define MORPHTARGETS_TEXTURE_STRIDE "+e.morphTextureStride:"",e.morphTargetsCount>0?"#define MORPHTARGETS_COUNT "+e.morphTargetsCount:"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+c:"",e.sizeAttenuation?"#define USE_SIZEATTENUATION":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.logarithmicDepthBuffer?"#define USE_LOGARITHMIC_DEPTH_BUFFER":"",e.reversedDepthBuffer?"#define USE_REVERSED_DEPTH_BUFFER":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","#ifdef USE_INSTANCING_MORPH","	uniform sampler2D morphTexture;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(Vo).join(`
`),m=[_p(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,d,e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.alphaToCoverage?"#define ALPHA_TO_COVERAGE":"",e.map?"#define USE_MAP":"",e.matcap?"#define USE_MATCAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+l:"",e.envMap?"#define "+h:"",e.envMap?"#define "+f:"",e.envMapPMREM?"#define ENVMAP_MAX_LOD "+e.envMapMaxLod+".0":"",e.envMapPMREM?"#define ENVMAP_SIZE "+e.envMapSize+".0":"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.packedNormalMap?"#define USE_PACKED_NORMALMAP":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoat?"#define USE_CLEARCOAT":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.diffuseRoughness?"#define USE_DIFFUSE_ROUGHNESS":"",e.diffuseRoughnessMap?"#define USE_DIFFUSE_ROUGHNESSMAP":"",e.dispersion?"#define USE_DISPERSION":"",e.retroreflection?"#define USE_RETROREFLECTION":"",e.iridescence?"#define USE_IRIDESCENCE":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaTest?"#define USE_ALPHATEST":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.sheen?"#define USE_SHEEN":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors||e.instancingColor?"#define USE_COLOR":"",e.vertexAlphas||e.batchingColor?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.gradientMap?"#define USE_GRADIENTMAP":"",e.flatShading?"#define FLAT_SHADED":"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+c:"",e.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",e.decodeVideoTextureEmissive?"#define DECODE_VIDEO_TEXTURE_EMISSIVE":"",e.logarithmicDepthBuffer?"#define USE_LOGARITHMIC_DEPTH_BUFFER":"",e.reversedDepthBuffer?"#define USE_REVERSED_DEPTH_BUFFER":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",e.toneMapping!==ri?"#define TONE_MAPPING":"",e.toneMapping!==ri?Nt.tonemapping_pars_fragment:"",e.toneMapping!==ri?Vy("toneMapping",e.toneMapping):"",e.dithering?"#define DITHERING":"",e.opaque?"#define OPAQUE":"",Nt.colorspace_pars_fragment,zy("linearToOutputTexel",e.outputColorSpace),Gy(),e.useDepthPacking?"#define DEPTH_PACKING "+e.depthPacking:"",`
`].filter(Vo).join(`
`)),o=su(o),o=pp(o,e),o=mp(o,e),a=su(a),a=pp(a,e),a=mp(a,e),o=gp(o),a=gp(a),e.isRawShaderMaterial!==!0&&(p=`#version 300 es
`,v=[u,"#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+v,m=["#define varying in",e.glslVersion===zh?"":"layout(location = 0) out highp vec4 pc_fragColor;",e.glslVersion===zh?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+m);let x=p+v+o,M=p+m+a,y=up(i,i.VERTEX_SHADER,x),S=up(i,i.FRAGMENT_SHADER,M);i.attachShader(g,y),i.attachShader(g,S),e.index0AttributeName!==void 0?i.bindAttribLocation(g,0,e.index0AttributeName):e.hasPositionAttribute===!0&&i.bindAttribLocation(g,0,"position"),i.linkProgram(g);function T(E){if(s.debug.checkShaderErrors){let L=i.getProgramInfoLog(g)||"",C=i.getShaderInfoLog(y)||"",U=i.getShaderInfoLog(S)||"",N=L.trim(),B=C.trim(),G=U.trim(),H=!0,tt=!0;if(i.getProgramParameter(g,i.LINK_STATUS)===!1)if(H=!1,typeof s.debug.onShaderError=="function")s.debug.onShaderError(i,g,y,S);else{let X=dp(i,y,"vertex"),j=dp(i,S,"fragment");Dt("WebGLProgram: Shader Error "+i.getError()+" - VALIDATE_STATUS "+i.getProgramParameter(g,i.VALIDATE_STATUS)+`

Material Name: `+E.name+`
Material Type: `+E.type+`

Program Info Log: `+N+`
`+X+`
`+j)}else N!==""?Tt("WebGLProgram: Program Info Log:",N):(B===""||G==="")&&(tt=!1);tt&&(E.diagnostics={runnable:H,programLog:N,vertexShader:{log:B,prefix:v},fragmentShader:{log:G,prefix:m}})}i.deleteShader(y),i.deleteShader(S),_=new Ar(i,g),b=Xy(i,g)}let _;this.getUniforms=function(){return _===void 0&&T(this),_};let b;this.getAttributes=function(){return b===void 0&&T(this),b};let I=e.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return I===!1&&(I=i.getProgramParameter(g,Uy)),I},this.destroy=function(){n.releaseStatesOfProgram(this),i.deleteProgram(g),this.program=void 0},this.type=e.shaderType,this.name=e.shaderName,this.id=Fy++,this.cacheKey=t,this.usedTimes=1,this.program=g,this.vertexShader=y,this.fragmentShader=S,this}var iv=0,ru=class{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(t,e,n){let i=this._getShaderCacheForMaterial(t);return i.has(e)===!1&&(i.add(e),e.usedTimes++),i.has(n)===!1&&(i.add(n),n.usedTimes++),this}remove(t){let e=this.materialCache.get(t);for(let n of e)n.usedTimes--,n.usedTimes===0&&this.shaderCache.delete(n.code);return this.materialCache.delete(t),this}getVertexShaderStage(t){return this._getShaderStage(t.vertexShader)}getFragmentShaderStage(t){return this._getShaderStage(t.fragmentShader)}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(t){let e=this.materialCache,n=e.get(t);return n===void 0&&(n=new Set,e.set(t,n)),n}_getShaderStage(t){let e=this.shaderCache,n=e.get(t);return n===void 0&&(n=new ou(t),e.set(t,n)),n}},ou=class{constructor(t){this.id=iv++,this.code=t,this.usedTimes=0}};function sv(s){return s===$i||s===Oo||s===Bo}function rv(s,t,e,n,i,r){let o=new or,a=new ru,c=new Set,l=[],h=new Map,f=n.logarithmicDepthBuffer,u={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distance",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function d(_){return c.add(_),_===0?"uv":`uv${_}`}function g(_,b,I,E,L,C){let U=E.fog,N=L.geometry,B=_.isMeshStandardMaterial||_.isMeshLambertMaterial||_.isMeshPhongMaterial?E.environment:null,G=_.isMeshStandardMaterial||_.isMeshLambertMaterial&&!_.envMap||_.isMeshPhongMaterial&&!_.envMap,H=t.get(_.envMap||B,G),tt=u[_.type],X=n.precision;_.precision!==null&&(X=n.getMaxPrecision(_.precision),X!==_.precision&&Tt("WebGLProgram.getParameters:",_.precision,"not supported, using",X,"instead."));let j=N.morphAttributes.position||N.morphAttributes.normal||N.morphAttributes.color,Q=j!==void 0?j.length:0,yt=0;N.morphAttributes.position!==void 0&&(yt=1),N.morphAttributes.normal!==void 0&&(yt=2),N.morphAttributes.color!==void 0&&(yt=3);let Ut,Z,lt,xt;if(tt){let pt=ci[tt];Ut=pt.vertexShader,Z=pt.fragmentShader}else{Ut=_.vertexShader,Z=_.fragmentShader;let pt=a.getVertexShaderStage(_),oe=a.getFragmentShaderStage(_);a.update(_,pt,oe),lt=pt.id,xt=oe.id}let Ct=s.getRenderTarget(),dt=s.state.buffers.depth.getReversed(),Ot=L.isInstancedMesh===!0,Ce=L.isBatchedMesh===!0,It=!!_.map,jt=!!_.matcap,le=!!H,qt=le&&H.isPMREMTexture===!0,Ze=!!_.aoMap,Be=!!_.lightMap,_n=!!_.bumpMap&&_.wireframe===!1,Se=!!_.normalMap,Jn=!!_.displacementMap,He=!!_.emissiveMap,Cn=!!_.metalnessMap,Pn=!!_.roughnessMap,In=_.anisotropy>0,O=_.clearcoat>0,Ln=_.diffuseRoughness>0,ge=_.dispersion>0,_e=_.retroreflectivity>0,ft=_.iridescence>0,ze=_.sheen>0,Lt=_.transmission>0,Bt=In&&!!_.anisotropyMap,P=O&&!!_.clearcoatMap,w=O&&!!_.clearcoatNormalMap,k=O&&!!_.clearcoatRoughnessMap,et=Ln&&!!_.diffuseRoughnessMap,$=ft&&!!_.iridescenceMap,st=ft&&!!_.iridescenceThicknessMap,ht=ze&&!!_.sheenColorMap,Y=ze&&!!_.sheenRoughnessMap,K=!!_.specularMap,ot=!!_.specularColorMap,D=!!_.specularIntensityMap,J=Lt&&!!_.transmissionMap,q=Lt&&!!_.thicknessMap,at=!!_.gradientMap,it=!!_.alphaMap,rt=_.alphaTest>0,wt=!!_.alphaHash,Gt=!!_.extensions,nt=ri;_.toneMapped&&(Ct===null||Ct.isXRRenderTarget===!0)&&(nt=s.toneMapping);let Rt=qt?H.isCompressedCubeTexture?H.image[0].mipmaps:H.mipmaps:null,Vt={shaderID:tt,shaderType:_.type,shaderName:_.name,vertexShader:Ut,fragmentShader:Z,defines:_.defines,customVertexShaderID:lt,customFragmentShaderID:xt,isRawShaderMaterial:_.isRawShaderMaterial===!0,glslVersion:_.glslVersion,precision:X,batching:Ce,batchingColor:Ce&&L._colorsTexture!==null,instancing:Ot,instancingColor:Ot&&L.instanceColor!==null,instancingMorph:Ot&&L.morphTexture!==null,outputColorSpace:Ct===null?s.outputColorSpace:Ct.isXRRenderTarget===!0?Ct.texture.colorSpace:Ht.workingColorSpace,alphaToCoverage:!!_.alphaToCoverage,map:It,matcap:jt,envMap:le,envMapMode:le&&H.mapping,envMapPMREM:qt,envMapMaxLod:qt?Rt.length-1:null,envMapSize:qt?Rt[0].width:null,aoMap:Ze,lightMap:Be,bumpMap:_n,normalMap:Se,displacementMap:Jn,emissiveMap:He,normalMapObjectSpace:Se&&_.normalMapType===kd,normalMapTangentSpace:Se&&_.normalMapType===Gc,packedNormalMap:Se&&_.normalMapType===Gc&&sv(_.normalMap.format),metalnessMap:Cn,roughnessMap:Pn,anisotropy:In,anisotropyMap:Bt,clearcoat:O,clearcoatMap:P,clearcoatNormalMap:w,clearcoatRoughnessMap:k,diffuseRoughness:Ln,diffuseRoughnessMap:et,dispersion:ge,retroreflection:_e,iridescence:ft,iridescenceMap:$,iridescenceThicknessMap:st,sheen:ze,sheenColorMap:ht,sheenRoughnessMap:Y,specularMap:K,specularColorMap:ot,specularIntensityMap:D,transmission:Lt,transmissionMap:J,thicknessMap:q,gradientMap:at,opaque:_.transparent===!1&&_.blending===yr&&_.alphaToCoverage===!1,alphaMap:it,alphaTest:rt,alphaHash:wt,combine:_.combine,mapUv:It&&d(_.map.channel),aoMapUv:Ze&&d(_.aoMap.channel),lightMapUv:Be&&d(_.lightMap.channel),bumpMapUv:_n&&d(_.bumpMap.channel),normalMapUv:Se&&d(_.normalMap.channel),displacementMapUv:Jn&&d(_.displacementMap.channel),emissiveMapUv:He&&d(_.emissiveMap.channel),metalnessMapUv:Cn&&d(_.metalnessMap.channel),roughnessMapUv:Pn&&d(_.roughnessMap.channel),anisotropyMapUv:Bt&&d(_.anisotropyMap.channel),clearcoatMapUv:P&&d(_.clearcoatMap.channel),clearcoatNormalMapUv:w&&d(_.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:k&&d(_.clearcoatRoughnessMap.channel),diffuseRoughnessMapUv:et&&d(_.diffuseRoughnessMap.channel),iridescenceMapUv:$&&d(_.iridescenceMap.channel),iridescenceThicknessMapUv:st&&d(_.iridescenceThicknessMap.channel),sheenColorMapUv:ht&&d(_.sheenColorMap.channel),sheenRoughnessMapUv:Y&&d(_.sheenRoughnessMap.channel),specularMapUv:K&&d(_.specularMap.channel),specularColorMapUv:ot&&d(_.specularColorMap.channel),specularIntensityMapUv:D&&d(_.specularIntensityMap.channel),transmissionMapUv:J&&d(_.transmissionMap.channel),thicknessMapUv:q&&d(_.thicknessMap.channel),alphaMapUv:it&&d(_.alphaMap.channel),vertexTangents:!!N.attributes.tangent&&(Se||In),vertexNormals:!!N.attributes.normal,vertexColors:_.vertexColors,vertexAlphas:_.vertexColors===!0&&!!N.attributes.color&&N.attributes.color.itemSize===4,pointsUvs:L.isPoints===!0&&!!N.attributes.uv&&(It||it),fog:!!U,useFog:_.fog===!0,fogExp2:!!U&&U.isFogExp2,flatShading:_.wireframe===!1&&(_.flatShading===!0||N.attributes.normal===void 0&&Se===!1&&(_.isMeshLambertMaterial||_.isMeshPhongMaterial||_.isMeshStandardMaterial||_.isMeshPhysicalMaterial)),sizeAttenuation:_.sizeAttenuation===!0,logarithmicDepthBuffer:f,reversedDepthBuffer:dt,skinning:L.isSkinnedMesh===!0,hasPositionAttribute:N.attributes.position!==void 0,morphTargets:N.morphAttributes.position!==void 0,morphNormals:N.morphAttributes.normal!==void 0,morphColors:N.morphAttributes.color!==void 0,morphTargetsCount:Q,morphTextureStride:yt,numSunLights:b.sun.length,numDirLights:b.directional.length,numPointLights:b.point.length,numSpotLights:b.spot.length,numSpotLightMaps:b.spotLightMap.length,numRectAreaLights:b.rectArea.length,numHemiLights:b.hemi.length,numSunLightShadows:b.sunShadowMap.length,numDirLightShadows:b.directionalShadowMap.length,numPointLightShadows:b.pointShadowMap.length,numSpotLightShadows:b.spotShadowMap.length,numSpotLightShadowsWithMaps:b.numSpotLightShadowsWithMaps,numLightProbes:b.numLightProbes,numLightProbeGrids:C.filter(pt=>pt.texture!==null).length,numClippingPlanes:r.numPlanes,numClipIntersection:r.numIntersection,dithering:_.dithering,shadowMapEnabled:s.shadowMap.enabled&&I.length>0,shadowMapType:s.shadowMap.type,toneMapping:nt,decodeVideoTexture:It&&_.map.isVideoTexture===!0&&Ht.getTransfer(_.map.colorSpace)===se,decodeVideoTextureEmissive:He&&_.emissiveMap.isVideoTexture===!0&&Ht.getTransfer(_.emissiveMap.colorSpace)===se,premultipliedAlpha:_.premultipliedAlpha,doubleSided:_.side===Pe,flipSided:_.side===Ne,useDepthPacking:_.depthPacking>=0,depthPacking:_.depthPacking||0,index0AttributeName:_.index0AttributeName,extensionClipCullDistance:Gt&&_.extensions.clipCullDistance===!0&&e.has("WEBGL_clip_cull_distance"),extensionMultiDraw:(Gt&&_.extensions.multiDraw===!0||Ce)&&e.has("WEBGL_multi_draw"),rendererExtensionParallelShaderCompile:e.has("KHR_parallel_shader_compile"),customProgramCacheKey:_.customProgramCacheKey()};return Vt.vertexUv1s=c.has(1),Vt.vertexUv2s=c.has(2),Vt.vertexUv3s=c.has(3),c.clear(),Vt}function v(_){let b=[];if(_.shaderID?b.push(_.shaderID):(b.push(_.customVertexShaderID),b.push(_.customFragmentShaderID)),_.defines!==void 0)for(let I in _.defines)b.push(I),b.push(_.defines[I]);return _.isRawShaderMaterial===!1&&(m(b,_),p(b,_),b.push(s.outputColorSpace)),b.push(_.customProgramCacheKey),b.join()}function m(_,b){_.push(b.precision),_.push(b.outputColorSpace),_.push(b.envMapMode),_.push(b.envMapPMREM),_.push(b.envMapMaxLod),_.push(b.envMapSize),_.push(b.mapUv),_.push(b.alphaMapUv),_.push(b.lightMapUv),_.push(b.aoMapUv),_.push(b.bumpMapUv),_.push(b.normalMapUv),_.push(b.displacementMapUv),_.push(b.emissiveMapUv),_.push(b.metalnessMapUv),_.push(b.roughnessMapUv),_.push(b.anisotropyMapUv),_.push(b.clearcoatMapUv),_.push(b.clearcoatNormalMapUv),_.push(b.clearcoatRoughnessMapUv),_.push(b.diffuseRoughnessMapUv),_.push(b.iridescenceMapUv),_.push(b.iridescenceThicknessMapUv),_.push(b.sheenColorMapUv),_.push(b.sheenRoughnessMapUv),_.push(b.specularMapUv),_.push(b.specularColorMapUv),_.push(b.specularIntensityMapUv),_.push(b.transmissionMapUv),_.push(b.thicknessMapUv),_.push(b.combine),_.push(b.fogExp2),_.push(b.sizeAttenuation),_.push(b.morphTargetsCount),_.push(b.numSunLights),_.push(b.numDirLights),_.push(b.numPointLights),_.push(b.numSpotLights),_.push(b.numSpotLightMaps),_.push(b.numHemiLights),_.push(b.numRectAreaLights),_.push(b.numSunLightShadows),_.push(b.numDirLightShadows),_.push(b.numPointLightShadows),_.push(b.numSpotLightShadows),_.push(b.numSpotLightShadowsWithMaps),_.push(b.numLightProbes),_.push(b.numLightProbeGrids),_.push(b.shadowMapType),_.push(b.toneMapping),_.push(b.numClippingPlanes),_.push(b.numClipIntersection),_.push(b.depthPacking)}function p(_,b){o.disableAll(),b.instancing&&o.enable(0),b.instancingColor&&o.enable(1),b.instancingMorph&&o.enable(2),b.matcap&&o.enable(3),b.envMap&&o.enable(4),b.normalMapObjectSpace&&o.enable(5),b.normalMapTangentSpace&&o.enable(6),b.clearcoat&&o.enable(7),b.iridescence&&o.enable(8),b.alphaTest&&o.enable(9),b.vertexColors&&o.enable(10),b.vertexAlphas&&o.enable(11),b.vertexUv1s&&o.enable(12),b.vertexUv2s&&o.enable(13),b.vertexUv3s&&o.enable(14),b.vertexTangents&&o.enable(15),b.anisotropy&&o.enable(16),b.alphaHash&&o.enable(17),b.batching&&o.enable(18),b.dispersion&&o.enable(19),b.retroreflection&&o.enable(24),b.diffuseRoughness&&o.enable(25),b.batchingColor&&o.enable(20),b.gradientMap&&o.enable(21),b.packedNormalMap&&o.enable(22),b.vertexNormals&&o.enable(23),_.push(o.mask),o.disableAll(),b.fog&&o.enable(0),b.useFog&&o.enable(1),b.flatShading&&o.enable(2),b.logarithmicDepthBuffer&&o.enable(3),b.reversedDepthBuffer&&o.enable(4),b.skinning&&o.enable(5),b.morphTargets&&o.enable(6),b.morphNormals&&o.enable(7),b.morphColors&&o.enable(8),b.premultipliedAlpha&&o.enable(9),b.shadowMapEnabled&&o.enable(10),b.doubleSided&&o.enable(11),b.flipSided&&o.enable(12),b.useDepthPacking&&o.enable(13),b.dithering&&o.enable(14),b.transmission&&o.enable(15),b.sheen&&o.enable(16),b.opaque&&o.enable(17),b.pointsUvs&&o.enable(18),b.decodeVideoTexture&&o.enable(19),b.decodeVideoTextureEmissive&&o.enable(20),b.alphaToCoverage&&o.enable(21),b.numLightProbeGrids>0&&o.enable(22),b.hasPositionAttribute&&o.enable(23),_.push(o.mask)}function x(_){let b=u[_.type],I;if(b){let E=ci[b];I=jd.clone(E.uniforms)}else I=_.uniforms;return I}function M(_,b){let I=h.get(b);return I!==void 0?++I.usedTimes:(I=new nv(s,b,_,i),l.push(I),h.set(b,I)),I}function y(_){if(--_.usedTimes===0){let b=l.indexOf(_);l[b]=l[l.length-1],l.pop(),h.delete(_.cacheKey),_.destroy()}}function S(_){a.remove(_)}function T(){a.dispose()}return{getParameters:g,getProgramCacheKey:v,getUniforms:x,acquireProgram:M,releaseProgram:y,releaseShaderCache:S,programs:l,dispose:T}}function ov(){let s=new WeakMap;function t(o){return s.has(o)}function e(o){let a=s.get(o);return a===void 0&&(a={},s.set(o,a)),a}function n(o){s.delete(o)}function i(o,a,c){s.get(o)[a]=c}function r(){s=new WeakMap}return{has:t,get:e,remove:n,update:i,dispose:r}}function av(s,t){return s.groupOrder!==t.groupOrder?s.groupOrder-t.groupOrder:s.renderOrder!==t.renderOrder?s.renderOrder-t.renderOrder:s.material.id!==t.material.id?s.material.id-t.material.id:s.materialVariant!==t.materialVariant?s.materialVariant-t.materialVariant:s.z!==t.z?s.z-t.z:s.id-t.id}function xp(s,t){return s.groupOrder!==t.groupOrder?s.groupOrder-t.groupOrder:s.renderOrder!==t.renderOrder?s.renderOrder-t.renderOrder:s.z!==t.z?t.z-s.z:s.id-t.id}function yp(){let s=[],t=0,e=[],n=[],i=[];function r(){t=0,e.length=0,n.length=0,i.length=0}function o(u){let d=0;return u.isInstancedMesh&&(d+=2),u.isSkinnedMesh&&(d+=1),d}function a(u,d,g,v,m,p){let x=s[t];return x===void 0?(x={id:u.id,object:u,geometry:d,material:g,materialVariant:o(u),groupOrder:v,renderOrder:u.renderOrder,z:m,group:p},s[t]=x):(x.id=u.id,x.object=u,x.geometry=d,x.material=g,x.materialVariant=o(u),x.groupOrder=v,x.renderOrder=u.renderOrder,x.z=m,x.group=p),t++,x}function c(u,d,g,v,m,p,x){x.reversedDepth===!0&&(m=-m);let M=a(u,d,g,v,m,p);g.transmission>0?n.push(M):g.transparent===!0?i.push(M):e.push(M)}function l(u,d,g,v,m,p){let x=a(u,d,g,v,m,p);g.transmission>0?n.unshift(x):g.transparent===!0?i.unshift(x):e.unshift(x)}function h(u,d){e.length>1&&e.sort(u||av),n.length>1&&n.sort(d||xp),i.length>1&&i.sort(d||xp)}function f(){for(let u=t,d=s.length;u<d;u++){let g=s[u];if(g.id===null)break;g.id=null,g.object=null,g.geometry=null,g.material=null,g.group=null}}return{opaque:e,transmissive:n,transparent:i,init:r,push:c,unshift:l,finish:f,sort:h}}function cv(){let s=new WeakMap;function t(n,i){let r=s.get(n),o;return r===void 0?(o=new yp,s.set(n,[o])):i>=r.length?(o=new yp,r.push(o)):o=r[i],o}function e(){s=new WeakMap}return{get:t,dispose:e}}function lv(){let s={};return{get:function(t){if(s[t.id]!==void 0)return s[t.id];let e;switch(t.type){case"SunLight":case"DirectionalLight":e={direction:new R,color:new Pt};break;case"SpotLight":e={position:new R,direction:new R,color:new Pt,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":e={position:new R,color:new Pt,distance:0,decay:0};break;case"HemisphereLight":e={direction:new R,skyColor:new Pt,groundColor:new Pt};break;case"RectAreaLight":e={color:new Pt,position:new R,halfWidth:new R,halfHeight:new R};break}return s[t.id]=e,e}}}function hv(){let s={};return{get:function(t){if(s[t.id]!==void 0)return s[t.id];let e;switch(t.type){case"SunLight":case"DirectionalLight":e={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new At};break;case"SpotLight":e={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new At};break;case"PointLight":e={shadowIntensity:1,shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new At,shadowCameraNear:1,shadowCameraFar:1e3};break}return s[t.id]=e,e}}}var uv=0;function fv(s,t){return(t.castShadow?2:0)-(s.castShadow?2:0)+(t.map?1:0)-(s.map?1:0)}function dv(s){let t=new lv,e=hv(),n={version:0,hash:{sunLength:-1,directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numSunShadows:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],sun:[],sunShadow:[],sunShadowMap:[],sunShadowMatrix:[],sunShadowCascade:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let l=0;l<9;l++)n.probe.push(new R);let i=new R,r=new _t,o=new _t;function a(l){let h=0,f=0,u=0;for(let C=0;C<9;C++)n.probe[C].set(0,0,0);let d=0,g=0,v=0,m=0,p=0,x=0,M=0,y=0,S=0,T=0,_=0,b=0,I=0,E=0;l.sort(fv);for(let C=0,U=l.length;C<U;C++){let N=l[C],B=N.color,G=N.intensity,H=N.distance,tt=null;if(N.shadow&&N.shadow.map&&(N.shadow.map.texture.format===$i?tt=N.shadow.map.texture:tt=N.shadow.map.depthTexture||N.shadow.map.texture),N.isAmbientLight)h+=B.r*G,f+=B.g*G,u+=B.b*G;else if(N.isLightProbe){for(let X=0;X<9;X++)n.probe[X].addScaledVector(N.sh.coefficients[X],G);E++}else if(N.isSunLight){let X=t.get(N);if(X.color.copy(N.color).multiplyScalar(N.intensity),N.castShadow){let j=N.shadow,Q=e.get(N);Q.shadowIntensity=j.intensity,Q.shadowBias=j.bias,Q.shadowNormalBias=j.normalBias,Q.shadowRadius=j.radius,Q.shadowMapSize.copy(j.mapSize).multiply(j.getFrameExtents()),n.sunShadow[g]=Q,n.sunShadowMap[g]=tt;let yt=j.getViewportCount();for(let Ut=0;Ut<yt;Ut++)n.sunShadowMatrix[v+Ut]=j.getMatrix(Ut),n.sunShadowCascade[v+Ut]=j._cascadeData[Ut];v+=yt,g++}n.sun[d]=X,d++}else if(N.isDirectionalLight){let X=t.get(N);if(X.color.copy(N.color).multiplyScalar(N.intensity),N.castShadow){let j=N.shadow,Q=e.get(N);Q.shadowIntensity=j.intensity,Q.shadowBias=j.bias,Q.shadowNormalBias=j.normalBias,Q.shadowRadius=j.radius,Q.shadowMapSize=j.mapSize,n.directionalShadow[m]=Q,n.directionalShadowMap[m]=tt,n.directionalShadowMatrix[m]=N.shadow.matrix,S++}n.directional[m]=X,m++}else if(N.isSpotLight){let X=t.get(N);X.position.setFromMatrixPosition(N.matrixWorld),X.color.copy(B).multiplyScalar(G),X.distance=H,X.coneCos=Math.cos(N.angle),X.penumbraCos=Math.cos(N.angle*(1-N.penumbra)),X.decay=N.decay,n.spot[x]=X;let j=N.shadow;if(N.map&&(n.spotLightMap[b]=N.map,b++,j.updateMatrices(N),N.castShadow&&I++),n.spotLightMatrix[x]=j.matrix,N.castShadow){let Q=e.get(N);Q.shadowIntensity=j.intensity,Q.shadowBias=j.bias,Q.shadowNormalBias=j.normalBias,Q.shadowRadius=j.radius,Q.shadowMapSize=j.mapSize,n.spotShadow[x]=Q,n.spotShadowMap[x]=tt,_++}x++}else if(N.isRectAreaLight){let X=t.get(N);X.color.copy(B).multiplyScalar(G),X.halfWidth.set(N.width*.5,0,0),X.halfHeight.set(0,N.height*.5,0),n.rectArea[M]=X,M++}else if(N.isPointLight){let X=t.get(N);if(X.color.copy(N.color).multiplyScalar(N.intensity),X.distance=N.distance,X.decay=N.decay,N.castShadow){let j=N.shadow,Q=e.get(N);Q.shadowIntensity=j.intensity,Q.shadowBias=j.bias,Q.shadowNormalBias=j.normalBias,Q.shadowRadius=j.radius,Q.shadowMapSize=j.mapSize,Q.shadowCameraNear=j.camera.near,Q.shadowCameraFar=j.camera.far,n.pointShadow[p]=Q,n.pointShadowMap[p]=tt,n.pointShadowMatrix[p]=N.shadow.matrix,T++}n.point[p]=X,p++}else if(N.isHemisphereLight){let X=t.get(N);X.skyColor.copy(N.color).multiplyScalar(G),X.groundColor.copy(N.groundColor).multiplyScalar(G),n.hemi[y]=X,y++}}M>0&&(s.has("OES_texture_float_linear")===!0?(n.rectAreaLTC1=mt.LTC_FLOAT_1,n.rectAreaLTC2=mt.LTC_FLOAT_2):(n.rectAreaLTC1=mt.LTC_HALF_1,n.rectAreaLTC2=mt.LTC_HALF_2)),n.ambient[0]=h,n.ambient[1]=f,n.ambient[2]=u;let L=n.hash;(L.sunLength!==d||L.directionalLength!==m||L.pointLength!==p||L.spotLength!==x||L.rectAreaLength!==M||L.hemiLength!==y||L.numSunShadows!==g||L.numDirectionalShadows!==S||L.numPointShadows!==T||L.numSpotShadows!==_||L.numSpotMaps!==b||L.numLightProbes!==E)&&(n.sun.length=d,n.directional.length=m,n.spot.length=x,n.rectArea.length=M,n.point.length=p,n.hemi.length=y,n.sunShadow.length=g,n.sunShadowMap.length=g,n.sunShadowMatrix.length=v,n.sunShadowCascade.length=v,n.directionalShadow.length=S,n.directionalShadowMap.length=S,n.directionalShadowMatrix.length=S,n.pointShadow.length=T,n.pointShadowMap.length=T,n.pointShadowMatrix.length=T,n.spotShadow.length=_,n.spotShadowMap.length=_,n.spotLightMatrix.length=_+b-I,n.spotLightMap.length=b,n.numSpotLightShadowsWithMaps=I,n.numLightProbes=E,L.sunLength=d,L.directionalLength=m,L.pointLength=p,L.spotLength=x,L.rectAreaLength=M,L.hemiLength=y,L.numSunShadows=g,L.numDirectionalShadows=S,L.numPointShadows=T,L.numSpotShadows=_,L.numSpotMaps=b,L.numLightProbes=E,n.version=uv++)}function c(l,h){let f=0,u=0,d=0,g=0,v=0,m=0,p=h.matrixWorldInverse;for(let x=0,M=l.length;x<M;x++){let y=l[x];if(y.isSunLight){let S=n.sun[f];S.direction.setFromMatrixPosition(y.matrixWorld),S.direction.transformDirection(p),f++}else if(y.isDirectionalLight){let S=n.directional[u];S.direction.setFromMatrixPosition(y.matrixWorld),i.setFromMatrixPosition(y.target.matrixWorld),S.direction.sub(i),S.direction.transformDirection(p),u++}else if(y.isSpotLight){let S=n.spot[g];S.position.setFromMatrixPosition(y.matrixWorld),S.position.applyMatrix4(p),S.direction.setFromMatrixPosition(y.matrixWorld),i.setFromMatrixPosition(y.target.matrixWorld),S.direction.sub(i),S.direction.transformDirection(p),g++}else if(y.isRectAreaLight){let S=n.rectArea[v];S.position.setFromMatrixPosition(y.matrixWorld),S.position.applyMatrix4(p),o.identity(),r.copy(y.matrixWorld),r.premultiply(p),o.extractRotation(r),S.halfWidth.set(y.width*.5,0,0),S.halfHeight.set(0,y.height*.5,0),S.halfWidth.applyMatrix4(o),S.halfHeight.applyMatrix4(o),v++}else if(y.isPointLight){let S=n.point[d];S.position.setFromMatrixPosition(y.matrixWorld),S.position.applyMatrix4(p),d++}else if(y.isHemisphereLight){let S=n.hemi[m];S.direction.setFromMatrixPosition(y.matrixWorld),S.direction.transformDirection(p),m++}}}return{setup:a,setupView:c,state:n}}function vp(s){let t=new dv(s),e=[],n=[],i=[];function r(f){h.camera=f,e.length=0,n.length=0,i.length=0}function o(f){f.isLightProbeGrid?i.push(f):e.push(f)}function a(f){n.push(f)}function c(){t.setup(e),i.sort((f,u)=>f.priority-u.priority||f.id-u.id)}function l(f){t.setupView(e,f)}let h={lightsArray:e,shadowsArray:n,lightProbeGridArray:i,camera:null,lights:t,transmissionRenderTarget:{},textureUnits:0};return{init:r,state:h,setupLights:c,setupLightsView:l,pushLight:o,pushShadow:a}}function pv(s){let t=new WeakMap;function e(i,r=0){let o=t.get(i),a;return o===void 0?(a=new vp(s),t.set(i,[a])):r>=o.length?(a=new vp(s),o.push(a)):a=o[r],a}function n(){t=new WeakMap}return{get:e,dispose:n}}var mv=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,gv=`uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;
void main() {
	const float samples = float( VSM_SAMPLES );
	float mean = 0.0;
	float squared_mean = 0.0;
	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {
		float uvOffset = uvStart + i * uvStride;
		#ifdef HORIZONTAL_PASS
			vec2 distribution = texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ).rg;
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
		#else
			float depth = texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ).r;
			mean += depth;
			squared_mean += depth * depth;
		#endif
	}
	mean = mean / samples;
	squared_mean = squared_mean / samples;
	float std_dev = sqrt( max( 0.0, squared_mean - mean * mean ) );
	gl_FragColor = vec4( mean, std_dev, 0.0, 1.0 );
}`,_v=[new R(1,0,0),new R(-1,0,0),new R(0,1,0),new R(0,-1,0),new R(0,0,1),new R(0,0,-1)],xv=[new R(0,-1,0),new R(0,-1,0),new R(0,0,1),new R(0,0,-1),new R(0,-1,0),new R(0,-1,0)],Mp=new _t,ko=new R,tu=new R;function yv(s,t,e){let n=new Ki,i=new At,r=new At,o=new Zt,a=new Ya,c=new Ka,l={},h=e.maxTextureSize,f={[pn]:Ne,[Ne]:pn,[Pe]:Pe},u=new ei({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new At},radius:{value:4}},vertexShader:mv,fragmentShader:gv}),d=u.clone();d.defines.HORIZONTAL_PASS=1;let g=new ye;g.setAttribute("position",new Te(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));let v=new Ee(g,u),m=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=Eo;let p=this.type;this.render=function(T,_,b){if(m.enabled===!1||m.autoUpdate===!1&&m.needsUpdate===!1||T.length===0)return;this.type===gd&&(Tt("WebGLShadowMap: PCFSoftShadowMap has been removed. Using PCFShadowMap instead."),this.type=Eo);let I=s.getRenderTarget(),E=s.getActiveCubeFace(),L=s.getActiveMipmapLevel(),C=s.state;C.setBlending(Ts),C.buffers.depth.getReversed()===!0?C.buffers.color.setClear(0,0,0,0):C.buffers.color.setClear(1,1,1,1),C.buffers.depth.setTest(!0),C.setScissorTest(!1);let U=p!==this.type;U&&_.traverse(function(N){N.material&&(Array.isArray(N.material)?N.material.forEach(B=>B.needsUpdate=!0):N.material.needsUpdate=!0)});for(let N=0,B=T.length;N<B;N++){let G=T[N],H=G.shadow;if(H===void 0){Tt("WebGLShadowMap:",G,"has no shadow.");continue}if(H.autoUpdate===!1&&H.needsUpdate===!1)continue;i.copy(H.mapSize);let tt=H.getFrameExtents();i.multiply(tt),r.copy(H.mapSize),(i.x>h||i.y>h)&&(i.x>h&&(r.x=Math.floor(h/tt.x),i.x=r.x*tt.x,H.mapSize.x=r.x),i.y>h&&(r.y=Math.floor(h/tt.y),i.y=r.y*tt.y,H.mapSize.y=r.y));let X=s.state.buffers.depth.getReversed();if(H.camera._reversedDepth=X,H.map===null||U===!0){if(H.map!==null&&(H.map.depthTexture!==null&&(H.map.depthTexture.dispose(),H.map.depthTexture=null),H.map.dispose()),this.type===xr){if(G.isPointLight){Tt("WebGLShadowMap: VSM shadow maps are not supported for PointLights. Use PCF or BasicShadowMap instead.");continue}H.map=new je(i.x,i.y,{format:$i,type:cn,minFilter:we,magFilter:we,generateMipmaps:!1}),H.map.texture.name=G.name+".shadowMap",H.map.depthTexture=new Ei(i.x,i.y,An),H.map.depthTexture.name=G.name+".shadowMapDepth",H.map.depthTexture.format=bi,H.map.depthTexture.compareFunction=null,H.map.depthTexture.minFilter=xe,H.map.depthTexture.magFilter=xe}else G.isPointLight?(H.map=new Ps(i.x),H.map.depthTexture=new go(i.x,Yn)):(H.map=new je(i.x,i.y),H.map.depthTexture=new Ei(i.x,i.y,Yn)),H.map.depthTexture.name=G.name+".shadowMap",H.map.depthTexture.format=bi,this.type===Eo?(H.map.depthTexture.compareFunction=X?Fh:Uh,H.map.depthTexture.minFilter=we,H.map.depthTexture.magFilter=we):(H.map.depthTexture.compareFunction=null,H.map.depthTexture.minFilter=xe,H.map.depthTexture.magFilter=xe);H.camera.updateProjectionMatrix()}H.map.isWebGLCubeRenderTarget!==!0&&(H.map.width!==i.x||H.map.height!==i.y)&&H.map.setSize(i.x,i.y);let j=H.map.isWebGLCubeRenderTarget?6:H.getViewportCount();G.isPointLight!==!0&&H.updateMatrices(G,b);let Q=(H.camera.layers.mask&4294967294)!==0?H.camera.layers:b.layers;for(let yt=0;yt<j;yt++){let Ut=H.getCamera(yt);if(G.isPointLight){let Z=H.camera,lt=H.matrix,xt=G.distance||Z.far;xt!==Z.far&&(Z.far=xt,Z.updateProjectionMatrix()),ko.setFromMatrixPosition(G.matrixWorld),Z.position.copy(ko),tu.copy(Z.position),tu.add(_v[yt]),Z.up.copy(xv[yt]),Z.lookAt(tu),Z.updateMatrixWorld(),lt.makeTranslation(-ko.x,-ko.y,-ko.z),Mp.multiplyMatrices(Z.projectionMatrix,Z.matrixWorldInverse),H._frustum.setFromProjectionMatrix(Mp,Z.coordinateSystem,Z.reversedDepth)}if(H.map.isWebGLCubeRenderTarget)s.setRenderTarget(H.map,yt),s.clear();else{yt===0&&(s.setRenderTarget(H.map),s.clear());let Z=H.getViewport(yt);o.set(r.x*Z.x,r.y*Z.y,r.x*Z.z,r.y*Z.w),C.viewport(o)}n=H.getFrustum(yt),y(_,b,Ut,G,Q,this.type)}H.isPointLightShadow!==!0&&this.type===xr&&x(H,b),H.needsUpdate=!1}p=this.type,m.needsUpdate=!1,s.setRenderTarget(I,E,L)};function x(T,_){let b=t.update(v);u.defines.VSM_SAMPLES!==T.blurSamples&&(u.defines.VSM_SAMPLES=T.blurSamples,d.defines.VSM_SAMPLES=T.blurSamples,u.needsUpdate=!0,d.needsUpdate=!0),T.mapPass===null?T.mapPass=new je(i.x,i.y,{format:$i,type:cn}):(T.mapPass.width!==T.map.width||T.mapPass.height!==T.map.height)&&T.mapPass.setSize(T.map.width,T.map.height),u.uniforms.shadow_pass.value=T.map.depthTexture,u.uniforms.resolution.value.set(T.map.width,T.map.height),u.uniforms.radius.value=T.radius,s.setRenderTarget(T.mapPass),s.clear(),s.renderBufferDirect(_,null,b,u,v,null),d.uniforms.shadow_pass.value=T.mapPass.texture,d.uniforms.resolution.value.set(T.map.width,T.map.height),d.uniforms.radius.value=T.radius,s.setRenderTarget(T.map),s.clear(),s.renderBufferDirect(_,null,b,d,v,null)}function M(T,_,b,I){let E=null,L=b.isPointLight===!0?T.customDistanceMaterial:T.customDepthMaterial;if(L!==void 0)E=L;else if(E=b.isPointLight===!0?c:a,s.localClippingEnabled&&_.clipShadows===!0&&Array.isArray(_.clippingPlanes)&&_.clippingPlanes.length!==0||_.displacementMap&&_.displacementScale!==0||_.alphaMap&&_.alphaTest>0||_.map&&_.alphaTest>0||_.alphaToCoverage===!0){let C=E.uuid,U=_.uuid,N=l[C];N===void 0&&(N={},l[C]=N);let B=N[U];B===void 0&&(B=E.clone(),N[U]=B,_.addEventListener("dispose",S)),E=B}if(E.visible=_.visible,E.wireframe=_.wireframe,I===xr?E.side=_.shadowSide!==null?_.shadowSide:_.side:E.side=_.shadowSide!==null?_.shadowSide:f[_.side],E.alphaMap=_.alphaMap,E.alphaTest=_.alphaToCoverage===!0?.5:_.alphaTest,E.map=_.map,E.clipShadows=_.clipShadows,E.clippingPlanes=_.clippingPlanes,E.clipIntersection=_.clipIntersection,E.displacementMap=_.displacementMap,E.displacementScale=_.displacementScale,E.displacementBias=_.displacementBias,E.wireframeLinewidth=_.wireframeLinewidth,E.linewidth=_.linewidth,b.isPointLight===!0&&E.isMeshDistanceMaterial===!0){let C=s.properties.get(E);C.light=b}return E}function y(T,_,b,I,E,L){if(T.visible===!1)return;if(T.layers.test(E)&&(T.isMesh||T.isLine||T.isPoints)&&(T.castShadow||T.receiveShadow&&L===xr)&&(!T.frustumCulled||T.intersectsFrustum(n))){T.modelViewMatrix.multiplyMatrices(b.matrixWorldInverse,T.matrixWorld);let N=t.update(T),B=T.material;if(Array.isArray(B)){let G=N.groups;for(let H=0,tt=G.length;H<tt;H++){let X=G[H],j=B[X.materialIndex];if(j&&j.visible){let Q=M(T,j,I,L);T.onBeforeShadow(s,T,_,b,N,Q,X),s.renderBufferDirect(b,null,N,Q,T,X),T.onAfterShadow(s,T,_,b,N,Q,X)}}}else if(B.visible){let G=M(T,B,I,L);T.onBeforeShadow(s,T,_,b,N,G,null),s.renderBufferDirect(b,null,N,G,T,null),T.onAfterShadow(s,T,_,b,N,G,null)}}let U=T.children;for(let N=0,B=U.length;N<B;N++)y(U[N],_,b,I,E,L)}function S(T){T.target.removeEventListener("dispose",S);for(let b in l){let I=l[b],E=T.target.uuid;E in I&&(I[E].dispose(),delete I[E])}}}function vv(s,t){function e(){let D=!1,J=new Zt,q=null,at=new Zt(0,0,0,0);return{setMask:function(it){q!==it&&!D&&(s.colorMask(it,it,it,it),q=it)},setLocked:function(it){D=it},setClear:function(it,rt,wt,Gt,nt){nt===!0&&(it*=Gt,rt*=Gt,wt*=Gt),J.set(it,rt,wt,Gt),at.equals(J)===!1&&(s.clearColor(it,rt,wt,Gt),at.copy(J))},reset:function(){D=!1,q=null,at.set(-1,0,0,0)}}}function n(){let D=!1,J=!1,q=null,at=null,it=null;return{setReversed:function(rt){if(J!==rt){let wt=t.get("EXT_clip_control");rt?wt.clipControlEXT(wt.LOWER_LEFT_EXT,wt.ZERO_TO_ONE_EXT):wt.clipControlEXT(wt.LOWER_LEFT_EXT,wt.NEGATIVE_ONE_TO_ONE_EXT),J=rt;let Gt=it;it=null,this.setClear(Gt)}},getReversed:function(){return J},setTest:function(rt){rt?dt(s.DEPTH_TEST):Ot(s.DEPTH_TEST)},setMask:function(rt){q!==rt&&!D&&(s.depthMask(rt),q=rt)},setFunc:function(rt){if(J&&(rt=Jd[rt]),at!==rt){switch(rt){case Na:s.depthFunc(s.NEVER);break;case Da:s.depthFunc(s.ALWAYS);break;case Ua:s.depthFunc(s.LESS);break;case tr:s.depthFunc(s.LEQUAL);break;case Fa:s.depthFunc(s.EQUAL);break;case Oa:s.depthFunc(s.GEQUAL);break;case Ba:s.depthFunc(s.GREATER);break;case za:s.depthFunc(s.NOTEQUAL);break;default:s.depthFunc(s.LEQUAL)}at=rt}},setLocked:function(rt){D=rt},setClear:function(rt){it!==rt&&(it=rt,J&&(rt=1-rt),s.clearDepth(rt))},reset:function(){D=!1,q=null,at=null,it=null,J=!1}}}function i(){let D=!1,J=null,q=null,at=null,it=null,rt=null,wt=null,Gt=null,nt=null;return{setTest:function(Rt){D||(Rt?dt(s.STENCIL_TEST):Ot(s.STENCIL_TEST))},setMask:function(Rt){J!==Rt&&!D&&(s.stencilMask(Rt),J=Rt)},setFunc:function(Rt,Vt,pt){(q!==Rt||at!==Vt||it!==pt)&&(s.stencilFunc(Rt,Vt,pt),q=Rt,at=Vt,it=pt)},setOp:function(Rt,Vt,pt){(rt!==Rt||wt!==Vt||Gt!==pt)&&(s.stencilOp(Rt,Vt,pt),rt=Rt,wt=Vt,Gt=pt)},setLocked:function(Rt){D=Rt},setClear:function(Rt){nt!==Rt&&(s.clearStencil(Rt),nt=Rt)},reset:function(){D=!1,J=null,q=null,at=null,it=null,rt=null,wt=null,Gt=null,nt=null}}}let r=new e,o=new n,a=new i,c={},l=new WeakMap,h={},f={},u={},d=new WeakMap,g=[],v=null,m=!1,p=null,x=null,M=null,y=null,S=null,T=null,_=null,b=new Pt(0,0,0),I=0,E=!1,L=null,C=null,U=null,N=null,B=null,G=s.getParameter(s.MAX_COMBINED_TEXTURE_IMAGE_UNITS),H=!1,tt=0,X=s.getParameter(s.VERSION);X.indexOf("WebGL")!==-1?(tt=parseFloat(/^WebGL (\d)/.exec(X)[1]),H=tt>=1):X.indexOf("OpenGL ES")!==-1&&(tt=parseFloat(/^OpenGL ES (\d)/.exec(X)[1]),H=tt>=2);let j=null,Q={},yt=s.getParameter(s.SCISSOR_BOX),Ut=s.getParameter(s.VIEWPORT),Z=new Zt().fromArray(yt),lt=new Zt().fromArray(Ut);function xt(D,J,q,at){let it=new Uint8Array(4),rt=s.createTexture();s.bindTexture(D,rt),s.texParameteri(D,s.TEXTURE_MIN_FILTER,s.NEAREST),s.texParameteri(D,s.TEXTURE_MAG_FILTER,s.NEAREST);for(let wt=0;wt<q;wt++)D===s.TEXTURE_3D||D===s.TEXTURE_2D_ARRAY?s.texImage3D(J,0,s.RGBA,1,1,at,0,s.RGBA,s.UNSIGNED_BYTE,it):s.texImage2D(J+wt,0,s.RGBA,1,1,0,s.RGBA,s.UNSIGNED_BYTE,it);return rt}let Ct={};Ct[s.TEXTURE_2D]=xt(s.TEXTURE_2D,s.TEXTURE_2D,1),Ct[s.TEXTURE_CUBE_MAP]=xt(s.TEXTURE_CUBE_MAP,s.TEXTURE_CUBE_MAP_POSITIVE_X,6),Ct[s.TEXTURE_2D_ARRAY]=xt(s.TEXTURE_2D_ARRAY,s.TEXTURE_2D_ARRAY,1,1),Ct[s.TEXTURE_3D]=xt(s.TEXTURE_3D,s.TEXTURE_3D,1,1),r.setClear(0,0,0,1),o.setClear(1),a.setClear(0),dt(s.DEPTH_TEST),o.setFunc(tr),_n(!1),Se(yh),dt(s.CULL_FACE),Ze(Ts);function dt(D){h[D]!==!0&&(s.enable(D),h[D]=!0)}function Ot(D){h[D]!==!1&&(s.disable(D),h[D]=!1)}function Ce(D,J){return u[D]!==J?(s.bindFramebuffer(D,J),u[D]=J,D===s.DRAW_FRAMEBUFFER&&(u[s.FRAMEBUFFER]=J),D===s.FRAMEBUFFER&&(u[s.DRAW_FRAMEBUFFER]=J),!0):!1}function It(D,J){let q=g,at=!1;if(D){q=d.get(J),q===void 0&&(q=[],d.set(J,q));let it=D.textures;if(q.length!==it.length||q[0]!==s.COLOR_ATTACHMENT0){for(let rt=0,wt=it.length;rt<wt;rt++)q[rt]=s.COLOR_ATTACHMENT0+rt;q.length=it.length,at=!0}}else q[0]!==s.BACK&&(q[0]=s.BACK,at=!0);at&&s.drawBuffers(q)}function jt(D){return v!==D?(s.useProgram(D),v=D,!0):!1}let le={[ws]:s.FUNC_ADD,[xd]:s.FUNC_SUBTRACT,[yd]:s.FUNC_REVERSE_SUBTRACT};le[vd]=s.MIN,le[Md]=s.MAX;let qt={[Sd]:s.ZERO,[bd]:s.ONE,[Td]:s.SRC_COLOR,[Sh]:s.SRC_ALPHA,[Pd]:s.SRC_ALPHA_SATURATE,[Rd]:s.DST_COLOR,[Ad]:s.DST_ALPHA,[wd]:s.ONE_MINUS_SRC_COLOR,[bh]:s.ONE_MINUS_SRC_ALPHA,[Cd]:s.ONE_MINUS_DST_COLOR,[Ed]:s.ONE_MINUS_DST_ALPHA,[Id]:s.CONSTANT_COLOR,[Ld]:s.ONE_MINUS_CONSTANT_COLOR,[Nd]:s.CONSTANT_ALPHA,[Dd]:s.ONE_MINUS_CONSTANT_ALPHA};function Ze(D,J,q,at,it,rt,wt,Gt,nt,Rt){if(D===Ts){m===!0&&(Ot(s.BLEND),m=!1);return}if(m===!1&&(dt(s.BLEND),m=!0),D!==_d){if(D!==p||Rt!==E){if((x!==ws||S!==ws)&&(s.blendEquation(s.FUNC_ADD),x=ws,S=ws),Rt)switch(D){case yr:s.blendFuncSeparate(s.ONE,s.ONE_MINUS_SRC_ALPHA,s.ONE,s.ONE_MINUS_SRC_ALPHA);break;case Ro:s.blendFunc(s.ONE,s.ONE);break;case vh:s.blendFuncSeparate(s.ZERO,s.ONE_MINUS_SRC_COLOR,s.ZERO,s.ONE);break;case Mh:s.blendFuncSeparate(s.DST_COLOR,s.ONE_MINUS_SRC_ALPHA,s.ZERO,s.ONE);break;default:Dt("WebGLState: Invalid blending: ",D);break}else switch(D){case yr:s.blendFuncSeparate(s.SRC_ALPHA,s.ONE_MINUS_SRC_ALPHA,s.ONE,s.ONE_MINUS_SRC_ALPHA);break;case Ro:s.blendFuncSeparate(s.SRC_ALPHA,s.ONE,s.ONE,s.ONE);break;case vh:Dt("WebGLState: SubtractiveBlending requires material.premultipliedAlpha = true");break;case Mh:Dt("WebGLState: MultiplyBlending requires material.premultipliedAlpha = true");break;default:Dt("WebGLState: Invalid blending: ",D);break}M=null,y=null,T=null,_=null,b.set(0,0,0),I=0,p=D,E=Rt}return}it=it||J,rt=rt||q,wt=wt||at,(J!==x||it!==S)&&(s.blendEquationSeparate(le[J],le[it]),x=J,S=it),(q!==M||at!==y||rt!==T||wt!==_)&&(s.blendFuncSeparate(qt[q],qt[at],qt[rt],qt[wt]),M=q,y=at,T=rt,_=wt),(Gt.equals(b)===!1||nt!==I)&&(s.blendColor(Gt.r,Gt.g,Gt.b,nt),b.copy(Gt),I=nt),p=D,E=!1}function Be(D,J){D.side===Pe?Ot(s.CULL_FACE):dt(s.CULL_FACE);let q=D.side===Ne;J&&(q=!q),_n(q),D.blending===yr&&D.transparent===!1?Ze(Ts):Ze(D.blending,D.blendEquation,D.blendSrc,D.blendDst,D.blendEquationAlpha,D.blendSrcAlpha,D.blendDstAlpha,D.blendColor,D.blendAlpha,D.premultipliedAlpha),o.setFunc(D.depthFunc),o.setTest(D.depthTest),o.setMask(D.depthWrite),r.setMask(D.colorWrite);let at=D.stencilWrite;a.setTest(at),at&&(a.setMask(D.stencilWriteMask),a.setFunc(D.stencilFunc,D.stencilRef,D.stencilFuncMask),a.setOp(D.stencilFail,D.stencilZFail,D.stencilZPass)),He(D.polygonOffset,D.polygonOffsetFactor,D.polygonOffsetUnits),D.alphaToCoverage===!0?dt(s.SAMPLE_ALPHA_TO_COVERAGE):Ot(s.SAMPLE_ALPHA_TO_COVERAGE)}function _n(D){L!==D&&(D?s.frontFace(s.CW):s.frontFace(s.CCW),L=D)}function Se(D){D!==pd?(dt(s.CULL_FACE),D!==C&&(D===yh?s.cullFace(s.BACK):D===md?s.cullFace(s.FRONT):s.cullFace(s.FRONT_AND_BACK))):Ot(s.CULL_FACE),C=D}function Jn(D){D!==U&&(H&&s.lineWidth(D),U=D)}function He(D,J,q){D?(dt(s.POLYGON_OFFSET_FILL),(N!==J||B!==q)&&(N=J,B=q,o.getReversed()&&(J=-J,q=-q),s.polygonOffset(J,q))):Ot(s.POLYGON_OFFSET_FILL)}function Cn(D){D?dt(s.SCISSOR_TEST):Ot(s.SCISSOR_TEST)}function Pn(D){D===void 0&&(D=s.TEXTURE0+G-1),j!==D&&(s.activeTexture(D),j=D)}function In(D,J,q){q===void 0&&(j===null?q=s.TEXTURE0+G-1:q=j);let at=Q[q];at===void 0&&(at={type:void 0,texture:void 0},Q[q]=at),(at.type!==D||at.texture!==J)&&(j!==q&&(s.activeTexture(q),j=q),s.bindTexture(D,J||Ct[D]),at.type=D,at.texture=J)}function O(){let D=Q[j];D!==void 0&&D.type!==void 0&&(s.bindTexture(D.type,null),D.type=void 0,D.texture=void 0)}function Ln(){try{s.compressedTexImage2D(...arguments)}catch(D){Dt("WebGLState:",D)}}function ge(){try{s.compressedTexImage3D(...arguments)}catch(D){Dt("WebGLState:",D)}}function _e(){try{s.texSubImage2D(...arguments)}catch(D){Dt("WebGLState:",D)}}function ft(){try{s.texSubImage3D(...arguments)}catch(D){Dt("WebGLState:",D)}}function ze(){try{s.compressedTexSubImage2D(...arguments)}catch(D){Dt("WebGLState:",D)}}function Lt(){try{s.compressedTexSubImage3D(...arguments)}catch(D){Dt("WebGLState:",D)}}function Bt(){try{s.texStorage2D(...arguments)}catch(D){Dt("WebGLState:",D)}}function P(){try{s.texStorage3D(...arguments)}catch(D){Dt("WebGLState:",D)}}function w(){try{s.texImage2D(...arguments)}catch(D){Dt("WebGLState:",D)}}function k(){try{s.texImage3D(...arguments)}catch(D){Dt("WebGLState:",D)}}function et(D){return f[D]!==void 0?f[D]:s.getParameter(D)}function $(D,J){f[D]!==J&&(s.pixelStorei(D,J),f[D]=J)}function st(D){Z.equals(D)===!1&&(s.scissor(D.x,D.y,D.z,D.w),Z.copy(D))}function ht(D){lt.equals(D)===!1&&(s.viewport(D.x,D.y,D.z,D.w),lt.copy(D))}function Y(D,J){let q=l.get(J);q===void 0&&(q=new WeakMap,l.set(J,q));let at=q.get(D);at===void 0&&(at=s.getUniformBlockIndex(J,D.name),s.uniformBlockBinding(J,at,at),q.set(D,at))}function K(D,J,q){let it=l.get(J).get(D);c[it]!==q&&(s.bindBufferBase(s.UNIFORM_BUFFER,it,q),c[it]=q)}function ot(){s.disable(s.BLEND),s.disable(s.CULL_FACE),s.disable(s.DEPTH_TEST),s.disable(s.POLYGON_OFFSET_FILL),s.disable(s.SCISSOR_TEST),s.disable(s.STENCIL_TEST),s.disable(s.SAMPLE_ALPHA_TO_COVERAGE),s.blendEquation(s.FUNC_ADD),s.blendFunc(s.ONE,s.ZERO),s.blendFuncSeparate(s.ONE,s.ZERO,s.ONE,s.ZERO),s.blendColor(0,0,0,0),s.colorMask(!0,!0,!0,!0),s.clearColor(0,0,0,0),s.depthMask(!0),s.depthFunc(s.LESS),o.setReversed(!1),s.clearDepth(1),s.stencilMask(4294967295),s.stencilFunc(s.ALWAYS,0,4294967295),s.stencilOp(s.KEEP,s.KEEP,s.KEEP),s.clearStencil(0),s.cullFace(s.BACK),s.frontFace(s.CCW),s.polygonOffset(0,0),s.activeTexture(s.TEXTURE0),s.bindFramebuffer(s.FRAMEBUFFER,null),s.bindFramebuffer(s.DRAW_FRAMEBUFFER,null),s.bindFramebuffer(s.READ_FRAMEBUFFER,null),s.useProgram(null),s.lineWidth(1),s.scissor(0,0,s.canvas.width,s.canvas.height),s.viewport(0,0,s.canvas.width,s.canvas.height),s.pixelStorei(s.PACK_ALIGNMENT,4),s.pixelStorei(s.UNPACK_ALIGNMENT,4),s.pixelStorei(s.UNPACK_FLIP_Y_WEBGL,!1),s.pixelStorei(s.UNPACK_PREMULTIPLY_ALPHA_WEBGL,!1),s.pixelStorei(s.UNPACK_COLORSPACE_CONVERSION_WEBGL,s.BROWSER_DEFAULT_WEBGL),s.pixelStorei(s.PACK_ROW_LENGTH,0),s.pixelStorei(s.PACK_SKIP_PIXELS,0),s.pixelStorei(s.PACK_SKIP_ROWS,0),s.pixelStorei(s.UNPACK_ROW_LENGTH,0),s.pixelStorei(s.UNPACK_IMAGE_HEIGHT,0),s.pixelStorei(s.UNPACK_SKIP_PIXELS,0),s.pixelStorei(s.UNPACK_SKIP_ROWS,0),s.pixelStorei(s.UNPACK_SKIP_IMAGES,0),h={},f={},j=null,Q={},u={},c={},d=new WeakMap,g=[],v=null,m=!1,p=null,x=null,M=null,y=null,S=null,T=null,_=null,b=new Pt(0,0,0),I=0,E=!1,L=null,C=null,U=null,N=null,B=null,Z.set(0,0,s.canvas.width,s.canvas.height),lt.set(0,0,s.canvas.width,s.canvas.height),r.reset(),o.reset(),a.reset()}return{buffers:{color:r,depth:o,stencil:a},enable:dt,disable:Ot,bindFramebuffer:Ce,drawBuffers:It,useProgram:jt,setBlending:Ze,setMaterial:Be,setFlipSided:_n,setCullFace:Se,setLineWidth:Jn,setPolygonOffset:He,setScissorTest:Cn,activeTexture:Pn,bindTexture:In,unbindTexture:O,compressedTexImage2D:Ln,compressedTexImage3D:ge,texImage2D:w,texImage3D:k,pixelStorei:$,getParameter:et,updateUBOMapping:Y,uniformBlockBinding:K,texStorage2D:Bt,texStorage3D:P,texSubImage2D:_e,texSubImage3D:ft,compressedTexSubImage2D:ze,compressedTexSubImage3D:Lt,scissor:st,viewport:ht,reset:ot}}function Mv(s,t,e,n,i,r,o){let a=t.has("WEBGL_multisampled_render_to_texture")?t.get("WEBGL_multisampled_render_to_texture"):null,c=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),l=new At,h=new WeakMap,f=new Set,u,d=new WeakMap,g=new Set,v=new FinalizationRegistry(P=>g.delete(P)),m=!1;try{m=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function p(P,w){return m?new OffscreenCanvas(P,w):ir("canvas")}function x(P,w,k){let et=1,$=Bt(P);if(($.width>k||$.height>k)&&(et=k/Math.max($.width,$.height)),et<1)if(typeof HTMLImageElement<"u"&&P instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&P instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&P instanceof ImageBitmap||typeof VideoFrame<"u"&&P instanceof VideoFrame){let st=Math.floor(et*$.width),ht=Math.floor(et*$.height);u===void 0&&(u=p(st,ht));let Y=w?p(st,ht):u;return Y.width=st,Y.height=ht,Y.getContext("2d").drawImage(P,0,0,st,ht),Tt("WebGLRenderer: Texture has been resized from ("+$.width+"x"+$.height+") to ("+st+"x"+ht+")."),Y}else return"data"in P&&Tt("WebGLRenderer: Image in DataTexture is too big ("+$.width+"x"+$.height+")."),P;return P}function M(P){return P.generateMipmaps}function y(P){s.generateMipmap(P)}function S(P){return P.isWebGLCubeRenderTarget?s.TEXTURE_CUBE_MAP:P.isWebGL3DRenderTarget?s.TEXTURE_3D:P.isWebGLArrayRenderTarget||P.isCompressedArrayTexture?s.TEXTURE_2D_ARRAY:s.TEXTURE_2D}function T(P,w,k,et,$,st=!1){if(P!==null){if(s[P]!==void 0)return s[P];Tt("WebGLRenderer: Attempt to use non-existing WebGL internal format '"+P+"'")}let ht;et&&(ht=t.get("EXT_texture_norm16"),ht||Tt("WebGLRenderer: Unable to use normalized textures without EXT_texture_norm16 extension"));let Y=w;if(w===s.RED&&(k===s.FLOAT&&(Y=s.R32F),k===s.HALF_FLOAT&&(Y=s.R16F),k===s.UNSIGNED_BYTE&&(Y=s.R8),k===s.UNSIGNED_SHORT&&ht&&(Y=ht.R16_EXT),k===s.SHORT&&ht&&(Y=ht.R16_SNORM_EXT)),w===s.RED_INTEGER&&(k===s.UNSIGNED_BYTE&&(Y=s.R8UI),k===s.UNSIGNED_SHORT&&(Y=s.R16UI),k===s.UNSIGNED_INT&&(Y=s.R32UI),k===s.BYTE&&(Y=s.R8I),k===s.SHORT&&(Y=s.R16I),k===s.INT&&(Y=s.R32I)),w===s.RG&&(k===s.FLOAT&&(Y=s.RG32F),k===s.HALF_FLOAT&&(Y=s.RG16F),k===s.UNSIGNED_BYTE&&(Y=s.RG8),k===s.UNSIGNED_SHORT&&ht&&(Y=ht.RG16_EXT),k===s.SHORT&&ht&&(Y=ht.RG16_SNORM_EXT)),w===s.RG_INTEGER&&(k===s.UNSIGNED_BYTE&&(Y=s.RG8UI),k===s.UNSIGNED_SHORT&&(Y=s.RG16UI),k===s.UNSIGNED_INT&&(Y=s.RG32UI),k===s.BYTE&&(Y=s.RG8I),k===s.SHORT&&(Y=s.RG16I),k===s.INT&&(Y=s.RG32I)),w===s.RGB_INTEGER&&(k===s.UNSIGNED_BYTE&&(Y=s.RGB8UI),k===s.UNSIGNED_SHORT&&(Y=s.RGB16UI),k===s.UNSIGNED_INT&&(Y=s.RGB32UI),k===s.BYTE&&(Y=s.RGB8I),k===s.SHORT&&(Y=s.RGB16I),k===s.INT&&(Y=s.RGB32I)),w===s.RGBA_INTEGER&&(k===s.UNSIGNED_BYTE&&(Y=s.RGBA8UI),k===s.UNSIGNED_SHORT&&(Y=s.RGBA16UI),k===s.UNSIGNED_INT&&(Y=s.RGBA32UI),k===s.BYTE&&(Y=s.RGBA8I),k===s.SHORT&&(Y=s.RGBA16I),k===s.INT&&(Y=s.RGBA32I)),w===s.RGB&&(k===s.UNSIGNED_SHORT&&ht&&(Y=ht.RGB16_EXT),k===s.SHORT&&ht&&(Y=ht.RGB16_SNORM_EXT),k===s.UNSIGNED_INT_5_9_9_9_REV&&(Y=s.RGB9_E5),k===s.UNSIGNED_INT_10F_11F_11F_REV&&(Y=s.R11F_G11F_B10F)),w===s.RGBA){let K=st?no:Ht.getTransfer($);k===s.FLOAT&&(Y=s.RGBA32F),k===s.HALF_FLOAT&&(Y=s.RGBA16F),k===s.UNSIGNED_BYTE&&(Y=K===se?s.SRGB8_ALPHA8:s.RGBA8),k===s.UNSIGNED_SHORT&&ht&&(Y=ht.RGBA16_EXT),k===s.SHORT&&ht&&(Y=ht.RGBA16_SNORM_EXT),k===s.UNSIGNED_SHORT_4_4_4_4&&(Y=s.RGBA4),k===s.UNSIGNED_SHORT_5_5_5_1&&(Y=s.RGB5_A1)}return(Y===s.R16F||Y===s.R32F||Y===s.RG16F||Y===s.RG32F||Y===s.RGBA16F||Y===s.RGBA32F)&&t.get("EXT_color_buffer_float"),Y}function _(P,w){let k;return P?w===null||w===Yn||w===Rs?k=s.DEPTH24_STENCIL8:w===An?k=s.DEPTH32F_STENCIL8:w===Tr&&(k=s.DEPTH24_STENCIL8,Tt("DepthTexture: 16 bit depth attachment is not supported with stencil. Using 24-bit attachment.")):w===null||w===Yn||w===Rs?k=s.DEPTH_COMPONENT24:w===An?k=s.DEPTH_COMPONENT32F:w===Tr&&(k=s.DEPTH_COMPONENT16),k}function b(P,w){return M(P)===!0||P.isFramebufferTexture&&P.minFilter!==xe&&P.minFilter!==we?Math.log2(Math.max(w.width,w.height))+1:P.mipmaps.length>0?P.mipmaps.length:P.isCompressedTexture&&Array.isArray(P.image)?w.mipmaps.length:1}function I(P){let w=new WeakRef(P);n.get(P).__ref=w,g.add(w),v.register(P,w,w)}function E(P){let w=n.get(P).__ref;w!==void 0&&(g.delete(w),v.unregister(w))}function L(P){U(P.target)}function C(P){N(P.target)}function U(P){P.removeEventListener("dispose",L),E(P),G(P),P.isVideoTexture&&h.delete(P),P.isHTMLTexture&&f.delete(P)}function N(P){P.removeEventListener("dispose",C),E(P),tt(P)}function B(){for(let P of g){let w=P.deref();w!==void 0&&(w.isRenderTarget===!0?N(w):U(w))}g.clear(),f.clear()}function G(P){let w=n.get(P);if(w.__webglInit===void 0)return;let k=P.source,et=d.get(k);if(et){let $=et[w.__cacheKey];$.usedTimes--,$.usedTimes===0&&H(P),Object.keys(et).length===0&&d.delete(k)}n.remove(P)}function H(P){let w=n.get(P);s.deleteTexture(w.__webglTexture);let k=P.source,et=d.get(k);delete et[w.__cacheKey],o.memory.textures--}function tt(P){let w=n.get(P);w.__depthDisposeCallback&&w.__depthDisposeCallback();let k=P.depthTexture;if(k&&k.renderTarget===P&&U(k),P.isWebGLCubeRenderTarget)for(let $=0;$<6;$++){if(Array.isArray(w.__webglFramebuffer[$]))for(let st=0;st<w.__webglFramebuffer[$].length;st++)s.deleteFramebuffer(w.__webglFramebuffer[$][st]);else s.deleteFramebuffer(w.__webglFramebuffer[$]);w.__webglDepthbuffer&&s.deleteRenderbuffer(w.__webglDepthbuffer[$])}else{if(Array.isArray(w.__webglFramebuffer))for(let $=0;$<w.__webglFramebuffer.length;$++)s.deleteFramebuffer(w.__webglFramebuffer[$]);else s.deleteFramebuffer(w.__webglFramebuffer);if(w.__webglDepthbuffer&&s.deleteRenderbuffer(w.__webglDepthbuffer),w.__webglMultisampledFramebuffer&&s.deleteFramebuffer(w.__webglMultisampledFramebuffer),w.__webglColorRenderbuffer)for(let $=0;$<w.__webglColorRenderbuffer.length;$++)w.__webglColorRenderbuffer[$]&&s.deleteRenderbuffer(w.__webglColorRenderbuffer[$]);w.__webglDepthRenderbuffer&&s.deleteRenderbuffer(w.__webglDepthRenderbuffer)}let et=P.textures;for(let $=0,st=et.length;$<st;$++){let ht=n.get(et[$]);ht.__webglTexture&&(s.deleteTexture(ht.__webglTexture),o.memory.textures--),n.remove(et[$])}n.remove(P)}let X=0;function j(){X=0}function Q(){return X}function yt(P){X=P}function Ut(){let P=X;return P>=i.maxTextures&&Tt("WebGLTextures: Trying to use "+(P+1)+" texture units while this GPU supports only "+i.maxTextures),X+=1,P}function Z(P){let w=[];return w.push(P.wrapS),w.push(P.wrapT),w.push(P.wrapR||0),w.push(P.magFilter),w.push(P.minFilter),w.push(P.anisotropy),w.push(P.internalFormat),w.push(P.format),w.push(P.type),w.push(P.generateMipmaps),w.push(P.mipmapsAutoUpdate),w.push(P.premultiplyAlpha),w.push(P.flipY),w.push(P.unpackAlignment),w.push(P.colorSpace),w.join()}function lt(P,w){let k=n.get(P);if(P.isVideoTexture&&ze(P),P.isRenderTargetTexture===!1&&P.isExternalTexture!==!0&&P.version>0&&k.__version!==P.version){let et=P.image;if(et===null)Tt("WebGLRenderer: Texture marked for update but no image data found.");else if(et.complete===!1)Tt("WebGLRenderer: Texture marked for update but image is incomplete");else{Be(k,P,w);return}}else P.isExternalTexture&&(k.__webglTexture=P.sourceTexture?P.sourceTexture:null);e.bindTexture(s.TEXTURE_2D,k.__webglTexture,s.TEXTURE0+w)}function xt(P,w){let k=n.get(P);if(P.isRenderTargetTexture===!1&&P.version>0&&k.__version!==P.version){Be(k,P,w);return}else P.isExternalTexture&&(k.__webglTexture=P.sourceTexture?P.sourceTexture:null);e.bindTexture(s.TEXTURE_2D_ARRAY,k.__webglTexture,s.TEXTURE0+w)}function Ct(P,w){let k=n.get(P);if(P.isRenderTargetTexture===!1&&P.version>0&&k.__version!==P.version){Be(k,P,w);return}e.bindTexture(s.TEXTURE_3D,k.__webglTexture,s.TEXTURE0+w)}function dt(P,w){let k=n.get(P);if(P.version>0&&k.__version!==P.version){_n(k,P,w);return}e.bindTexture(s.TEXTURE_CUBE_MAP,k.__webglTexture,s.TEXTURE0+w)}let Ot={[Hn]:s.REPEAT,[xn]:s.CLAMP_TO_EDGE,[er]:s.MIRRORED_REPEAT},Ce={[xe]:s.NEAREST,[sc]:s.NEAREST_MIPMAP_NEAREST,[Es]:s.NEAREST_MIPMAP_LINEAR,[we]:s.LINEAR,[br]:s.LINEAR_MIPMAP_NEAREST,[Sn]:s.LINEAR_MIPMAP_LINEAR},It={[Gd]:s.NEVER,[Oh]:s.ALWAYS,[Hd]:s.LESS,[Uh]:s.LEQUAL,[Wd]:s.EQUAL,[Fh]:s.GEQUAL,[Xd]:s.GREATER,[qd]:s.NOTEQUAL};function jt(P,w){if(w.type===An&&t.has("OES_texture_float_linear")===!1&&(w.magFilter===we||w.magFilter===br||w.magFilter===Es||w.magFilter===Sn||w.minFilter===we||w.minFilter===br||w.minFilter===Es||w.minFilter===Sn)&&Tt("WebGLRenderer: Unable to use linear filtering with floating point textures. OES_texture_float_linear not supported on this device."),s.texParameteri(P,s.TEXTURE_WRAP_S,Ot[w.wrapS]),s.texParameteri(P,s.TEXTURE_WRAP_T,Ot[w.wrapT]),(P===s.TEXTURE_3D||P===s.TEXTURE_2D_ARRAY)&&s.texParameteri(P,s.TEXTURE_WRAP_R,Ot[w.wrapR]),s.texParameteri(P,s.TEXTURE_MAG_FILTER,Ce[w.magFilter]),s.texParameteri(P,s.TEXTURE_MIN_FILTER,Ce[w.minFilter]),w.compareFunction&&(s.texParameteri(P,s.TEXTURE_COMPARE_MODE,s.COMPARE_REF_TO_TEXTURE),s.texParameteri(P,s.TEXTURE_COMPARE_FUNC,It[w.compareFunction])),t.has("EXT_texture_filter_anisotropic")===!0){if(w.magFilter===xe||w.minFilter!==Es&&w.minFilter!==Sn||w.type===An&&t.has("OES_texture_float_linear")===!1)return;if(w.anisotropy>1||n.get(w).__currentAnisotropy){let k=t.get("EXT_texture_filter_anisotropic");s.texParameterf(P,k.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(w.anisotropy,i.getMaxAnisotropy())),n.get(w).__currentAnisotropy=w.anisotropy}}}function le(P,w){let k=!1;P.__webglInit===void 0&&(P.__webglInit=!0,w.addEventListener("dispose",L),I(w));let et=w.source,$=d.get(et);$===void 0&&($={},d.set(et,$));let st=Z(w);if(st!==P.__cacheKey){$[st]===void 0&&($[st]={texture:s.createTexture(),usedTimes:0},o.memory.textures++,k=!0),$[st].usedTimes++;let ht=$[P.__cacheKey];ht!==void 0&&($[P.__cacheKey].usedTimes--,ht.usedTimes===0&&H(w)),P.__cacheKey=st,P.__webglTexture=$[st].texture}return k}function qt(P,w,k){return Math.floor(Math.floor(P/k)/w)}function Ze(P,w,k,et){let st=P.updateRanges;if(st.length===0)e.texSubImage2D(s.TEXTURE_2D,0,0,0,w.width,w.height,k,et,w.data);else{st.sort((D,J)=>D.start-J.start);let ht=0;for(let D=1;D<st.length;D++){let J=st[ht],q=st[D],at=J.start+J.count,it=qt(q.start,w.width,4),rt=qt(J.start,w.width,4);q.start<=at+1&&it===rt&&qt(q.start+q.count-1,w.width,4)===it?J.count=Math.max(J.count,q.start+q.count-J.start):(++ht,st[ht]=q)}st.length=ht+1;let Y=e.getParameter(s.UNPACK_ROW_LENGTH),K=e.getParameter(s.UNPACK_SKIP_PIXELS),ot=e.getParameter(s.UNPACK_SKIP_ROWS);e.pixelStorei(s.UNPACK_ROW_LENGTH,w.width);for(let D=0,J=st.length;D<J;D++){let q=st[D],at=Math.floor(q.start/4),it=Math.ceil(q.count/4),rt=at%w.width,wt=Math.floor(at/w.width),Gt=it,nt=1;e.pixelStorei(s.UNPACK_SKIP_PIXELS,rt),e.pixelStorei(s.UNPACK_SKIP_ROWS,wt),e.texSubImage2D(s.TEXTURE_2D,0,rt,wt,Gt,nt,k,et,w.data)}P.clearUpdateRanges(),e.pixelStorei(s.UNPACK_ROW_LENGTH,Y),e.pixelStorei(s.UNPACK_SKIP_PIXELS,K),e.pixelStorei(s.UNPACK_SKIP_ROWS,ot)}}function Be(P,w,k){let et=s.TEXTURE_2D;(w.isDataArrayTexture||w.isCompressedArrayTexture)&&(et=s.TEXTURE_2D_ARRAY),w.isData3DTexture&&(et=s.TEXTURE_3D);let $=le(P,w),st=w.source;e.bindTexture(et,P.__webglTexture,s.TEXTURE0+k);let ht=n.get(st);if(st.version!==ht.__version||$===!0){if(e.activeTexture(s.TEXTURE0+k),(typeof ImageBitmap<"u"&&w.image instanceof ImageBitmap)===!1){let nt=Ht.getPrimaries(Ht.workingColorSpace),Rt=w.colorSpace===Ui?null:Ht.getPrimaries(w.colorSpace),Vt=w.colorSpace===Ui||nt===Rt?s.NONE:s.BROWSER_DEFAULT_WEBGL;e.pixelStorei(s.UNPACK_FLIP_Y_WEBGL,w.flipY),e.pixelStorei(s.UNPACK_PREMULTIPLY_ALPHA_WEBGL,w.premultiplyAlpha),e.pixelStorei(s.UNPACK_COLORSPACE_CONVERSION_WEBGL,Vt)}e.pixelStorei(s.UNPACK_ALIGNMENT,w.unpackAlignment);let K=x(w.image,!1,i.maxTextureSize);K=Lt(w,K);let ot=r.convert(w.format,w.colorSpace),D=r.convert(w.type),J=T(w.internalFormat,ot,D,w.normalized,w.colorSpace,w.isVideoTexture);jt(et,w);let q,at=w.mipmaps,it=w.isVideoTexture!==!0,rt=ht.__version===void 0||$===!0,wt=st.dataReady,Gt=b(w,K);if(w.isDepthTexture)J=_(w.format===Di,w.type),rt&&(it?e.texStorage2D(s.TEXTURE_2D,1,J,K.width,K.height):e.texImage2D(s.TEXTURE_2D,0,J,K.width,K.height,0,ot,D,null));else if(w.isDataTexture)if(at.length>0){it&&rt&&e.texStorage2D(s.TEXTURE_2D,Gt,J,at[0].width,at[0].height);for(let nt=0,Rt=at.length;nt<Rt;nt++)q=at[nt],it?wt&&e.texSubImage2D(s.TEXTURE_2D,nt,0,0,q.width,q.height,ot,D,q.data):e.texImage2D(s.TEXTURE_2D,nt,J,q.width,q.height,0,ot,D,q.data);w.generateMipmaps=!1}else it?(rt&&e.texStorage2D(s.TEXTURE_2D,Gt,J,K.width,K.height),wt&&Ze(w,K,ot,D)):e.texImage2D(s.TEXTURE_2D,0,J,K.width,K.height,0,ot,D,K.data);else if(w.isCompressedTexture)if(w.isCompressedArrayTexture){it&&rt&&e.texStorage3D(s.TEXTURE_2D_ARRAY,Gt,J,at[0].width,at[0].height,K.depth);for(let nt=0,Rt=at.length;nt<Rt;nt++)if(q=at[nt],w.format!==Fn)if(ot!==null)if(it){if(wt)if(w.layerUpdates.size>0){let Vt=Yh(q.width,q.height,w.format,w.type);for(let pt of w.layerUpdates){let oe=q.data.subarray(pt*Vt/q.data.BYTES_PER_ELEMENT,(pt+1)*Vt/q.data.BYTES_PER_ELEMENT);e.compressedTexSubImage3D(s.TEXTURE_2D_ARRAY,nt,0,0,pt,q.width,q.height,1,ot,oe)}}else e.compressedTexSubImage3D(s.TEXTURE_2D_ARRAY,nt,0,0,0,q.width,q.height,K.depth,ot,q.data)}else e.compressedTexImage3D(s.TEXTURE_2D_ARRAY,nt,J,q.width,q.height,K.depth,0,q.data,0,0);else Tt("WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()");else it?wt&&e.texSubImage3D(s.TEXTURE_2D_ARRAY,nt,0,0,0,q.width,q.height,K.depth,ot,D,q.data):e.texImage3D(s.TEXTURE_2D_ARRAY,nt,J,q.width,q.height,K.depth,0,ot,D,q.data);w.layerUpdates.size>0&&w.clearLayerUpdates()}else{it&&rt&&e.texStorage2D(s.TEXTURE_2D,Gt,J,at[0].width,at[0].height);for(let nt=0,Rt=at.length;nt<Rt;nt++)q=at[nt],w.format!==Fn?ot!==null?it?wt&&e.compressedTexSubImage2D(s.TEXTURE_2D,nt,0,0,q.width,q.height,ot,q.data):e.compressedTexImage2D(s.TEXTURE_2D,nt,J,q.width,q.height,0,q.data):Tt("WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):it?wt&&e.texSubImage2D(s.TEXTURE_2D,nt,0,0,q.width,q.height,ot,D,q.data):e.texImage2D(s.TEXTURE_2D,nt,J,q.width,q.height,0,ot,D,q.data)}else if(w.isDataArrayTexture)if(it){if(rt&&e.texStorage3D(s.TEXTURE_2D_ARRAY,Gt,J,K.width,K.height,K.depth),wt)if(w.layerUpdates.size>0){let nt=Yh(K.width,K.height,w.format,w.type);for(let Rt of w.layerUpdates){let Vt=K.data.subarray(Rt*nt/K.data.BYTES_PER_ELEMENT,(Rt+1)*nt/K.data.BYTES_PER_ELEMENT);e.texSubImage3D(s.TEXTURE_2D_ARRAY,0,0,0,Rt,K.width,K.height,1,ot,D,Vt)}w.clearLayerUpdates()}else e.texSubImage3D(s.TEXTURE_2D_ARRAY,0,0,0,0,K.width,K.height,K.depth,ot,D,K.data)}else e.texImage3D(s.TEXTURE_2D_ARRAY,0,J,K.width,K.height,K.depth,0,ot,D,K.data);else if(w.isData3DTexture)it?(rt&&e.texStorage3D(s.TEXTURE_3D,Gt,J,K.width,K.height,K.depth),wt&&e.texSubImage3D(s.TEXTURE_3D,0,0,0,0,K.width,K.height,K.depth,ot,D,K.data)):e.texImage3D(s.TEXTURE_3D,0,J,K.width,K.height,K.depth,0,ot,D,K.data);else if(w.isFramebufferTexture){if(rt)if(it)e.texStorage2D(s.TEXTURE_2D,Gt,J,K.width,K.height);else{let nt=K.width,Rt=K.height;for(let Vt=0;Vt<Gt;Vt++)e.texImage2D(s.TEXTURE_2D,Vt,J,nt,Rt,0,ot,D,null),nt>>=1,Rt>>=1}}else if(w.isHTMLTexture){if("texElementImage2D"in s){let nt=s.canvas;if(nt.hasAttribute("layoutsubtree")||nt.setAttribute("layoutsubtree","true"),K.parentNode!==nt){nt.appendChild(K),f.add(w),nt.onpaint=Rt=>{let Vt=Rt.changedElements;for(let pt of f)Vt.includes(pt.image)&&(pt.needsUpdate=!0)},nt.requestPaint();return}if(s.texElementImage2D.length===3)s.texElementImage2D(s.TEXTURE_2D,s.RGBA8,K);else{let Vt=s.RGBA,pt=s.RGBA,oe=s.UNSIGNED_BYTE;s.texElementImage2D(s.TEXTURE_2D,0,Vt,pt,oe,K)}s.texParameteri(s.TEXTURE_2D,s.TEXTURE_MIN_FILTER,s.LINEAR),s.texParameteri(s.TEXTURE_2D,s.TEXTURE_WRAP_S,s.CLAMP_TO_EDGE),s.texParameteri(s.TEXTURE_2D,s.TEXTURE_WRAP_T,s.CLAMP_TO_EDGE)}}else if(at.length>0){if(it&&rt){let nt=Bt(at[0]);e.texStorage2D(s.TEXTURE_2D,Gt,J,nt.width,nt.height)}for(let nt=0,Rt=at.length;nt<Rt;nt++)q=at[nt],it?wt&&e.texSubImage2D(s.TEXTURE_2D,nt,0,0,ot,D,q):e.texImage2D(s.TEXTURE_2D,nt,J,ot,D,q);w.generateMipmaps=!1}else if(it){if(rt){let nt=Bt(K);e.texStorage2D(s.TEXTURE_2D,Gt,J,nt.width,nt.height)}wt&&e.texSubImage2D(s.TEXTURE_2D,0,0,0,ot,D,K)}else e.texImage2D(s.TEXTURE_2D,0,J,ot,D,K);M(w)&&w.mipmapsAutoUpdate===!0&&y(et),ht.__version=st.version,w.onUpdate&&w.onUpdate(w)}P.__version=w.version}function _n(P,w,k){if(w.image.length!==6)return;let et=le(P,w),$=w.source;e.bindTexture(s.TEXTURE_CUBE_MAP,P.__webglTexture,s.TEXTURE0+k);let st=n.get($);if($.version!==st.__version||et===!0){e.activeTexture(s.TEXTURE0+k);let ht=Ht.getPrimaries(Ht.workingColorSpace),Y=w.colorSpace===Ui?null:Ht.getPrimaries(w.colorSpace),K=w.colorSpace===Ui||ht===Y?s.NONE:s.BROWSER_DEFAULT_WEBGL;e.pixelStorei(s.UNPACK_FLIP_Y_WEBGL,w.flipY),e.pixelStorei(s.UNPACK_PREMULTIPLY_ALPHA_WEBGL,w.premultiplyAlpha),e.pixelStorei(s.UNPACK_ALIGNMENT,w.unpackAlignment),e.pixelStorei(s.UNPACK_COLORSPACE_CONVERSION_WEBGL,K);let ot=w.isCompressedTexture||w.image[0].isCompressedTexture,D=w.image[0]&&w.image[0].isDataTexture,J=[];for(let pt=0;pt<6;pt++)!ot&&!D?J[pt]=x(w.image[pt],!0,i.maxCubemapSize):J[pt]=D?w.image[pt].image:w.image[pt],J[pt]=Lt(w,J[pt]);let q=J[0],at=r.convert(w.format,w.colorSpace),it=r.convert(w.type),rt=T(w.internalFormat,at,it,w.normalized,w.colorSpace),wt=w.isVideoTexture!==!0,Gt=st.__version===void 0||et===!0,nt=$.dataReady,Rt=b(w,q);jt(s.TEXTURE_CUBE_MAP,w);let Vt;if(w.isDepthTexture){if(rt=_(w.format===Di,w.type),Gt)if(wt)e.texStorage2D(s.TEXTURE_CUBE_MAP,1,rt,q.width,q.height);else for(let pt=0;pt<6;pt++)e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,0,rt,q.width,q.height,0,at,it,null)}else if(ot){wt&&Gt&&e.texStorage2D(s.TEXTURE_CUBE_MAP,Rt,rt,q.width,q.height);for(let pt=0;pt<6;pt++){Vt=J[pt].mipmaps;for(let oe=0;oe<Vt.length;oe++){let We=Vt[oe];w.format!==Fn?at!==null?wt?nt&&e.compressedTexSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe,0,0,We.width,We.height,at,We.data):e.compressedTexImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe,rt,We.width,We.height,0,We.data):Tt("WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):wt?nt&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe,0,0,We.width,We.height,at,it,We.data):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe,rt,We.width,We.height,0,at,it,We.data)}}}else{if(Vt=w.mipmaps,wt&&Gt){Vt.length>0&&Rt++;let pt=Bt(J[0]);e.texStorage2D(s.TEXTURE_CUBE_MAP,Rt,rt,pt.width,pt.height)}for(let pt=0;pt<6;pt++)if(D){wt?nt&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,0,0,0,J[pt].width,J[pt].height,at,it,J[pt].data):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,0,rt,J[pt].width,J[pt].height,0,at,it,J[pt].data);for(let oe=0;oe<Vt.length;oe++){let ki=Vt[oe].image[pt].image;wt?nt&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe+1,0,0,ki.width,ki.height,at,it,ki.data):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe+1,rt,ki.width,ki.height,0,at,it,ki.data)}}else{wt?nt&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,0,0,0,at,it,J[pt]):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,0,rt,at,it,J[pt]);for(let oe=0;oe<Vt.length;oe++){let We=Vt[oe];wt?nt&&e.texSubImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe+1,0,0,at,it,We.image[pt]):e.texImage2D(s.TEXTURE_CUBE_MAP_POSITIVE_X+pt,oe+1,rt,at,it,We.image[pt])}}}M(w)&&w.mipmapsAutoUpdate===!0&&y(s.TEXTURE_CUBE_MAP),st.__version=$.version,w.onUpdate&&w.onUpdate(w)}P.__version=w.version}function Se(P,w,k,et,$,st){let ht=r.convert(k.format,k.colorSpace),Y=r.convert(k.type),K=T(k.internalFormat,ht,Y,k.normalized,k.colorSpace),ot=n.get(w),D=n.get(k);if(D.__renderTarget=w,!ot.__hasExternalTextures){let J=Math.max(1,w.width>>st),q=Math.max(1,w.height>>st);$===s.TEXTURE_3D||$===s.TEXTURE_2D_ARRAY?e.texImage3D($,st,K,J,q,w.depth,0,ht,Y,null):e.texImage2D($,st,K,J,q,0,ht,Y,null)}e.bindFramebuffer(s.FRAMEBUFFER,P),ft(w)?a.framebufferTexture2DMultisampleEXT(s.FRAMEBUFFER,et,$,D.__webglTexture,0,_e(w)):($===s.TEXTURE_2D||$>=s.TEXTURE_CUBE_MAP_POSITIVE_X&&$<=s.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&s.framebufferTexture2D(s.FRAMEBUFFER,et,$,D.__webglTexture,st),e.bindFramebuffer(s.FRAMEBUFFER,null)}function Jn(P,w,k){if(s.bindRenderbuffer(s.RENDERBUFFER,P),w.depthBuffer){let et=w.depthTexture,$=et&&et.isDepthTexture?et.type:null,st=_(w.stencilBuffer,$),ht=w.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT;ft(w)?a.renderbufferStorageMultisampleEXT(s.RENDERBUFFER,_e(w),st,w.width,w.height):k?s.renderbufferStorageMultisample(s.RENDERBUFFER,_e(w),st,w.width,w.height):s.renderbufferStorage(s.RENDERBUFFER,st,w.width,w.height),s.framebufferRenderbuffer(s.FRAMEBUFFER,ht,s.RENDERBUFFER,P)}else{let et=w.textures;for(let $=0;$<et.length;$++){let st=et[$],ht=r.convert(st.format,st.colorSpace),Y=r.convert(st.type),K=T(st.internalFormat,ht,Y,st.normalized,st.colorSpace);ft(w)?a.renderbufferStorageMultisampleEXT(s.RENDERBUFFER,_e(w),K,w.width,w.height):k?s.renderbufferStorageMultisample(s.RENDERBUFFER,_e(w),K,w.width,w.height):s.renderbufferStorage(s.RENDERBUFFER,K,w.width,w.height)}}s.bindRenderbuffer(s.RENDERBUFFER,null)}function He(P,w,k){let et=w.isWebGLCubeRenderTarget===!0;if(e.bindFramebuffer(s.FRAMEBUFFER,P),!(w.depthTexture&&w.depthTexture.isDepthTexture))throw new Error("THREE.WebGLTextures: renderTarget.depthTexture must be an instance of THREE.DepthTexture.");let $=n.get(w.depthTexture);$.__renderTarget=w;let st=et?w.depthTexture.image[0]:w.depthTexture.image;(!$.__webglTexture||st.width!==w.width||st.height!==w.height)&&(st.width=w.width,st.height=w.height,w.depthTexture.needsUpdate=!0),et?dt(w.depthTexture,0):lt(w.depthTexture,0);let ht=$.__webglTexture,Y=_e(w),K=et?s.TEXTURE_CUBE_MAP_POSITIVE_X+k:s.TEXTURE_2D,ot=w.depthTexture.format===Di?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT;if(w.depthTexture.format===bi)ft(w)?a.framebufferTexture2DMultisampleEXT(s.FRAMEBUFFER,ot,K,ht,0,Y):s.framebufferTexture2D(s.FRAMEBUFFER,ot,K,ht,0);else if(w.depthTexture.format===Di)ft(w)?a.framebufferTexture2DMultisampleEXT(s.FRAMEBUFFER,ot,K,ht,0,Y):s.framebufferTexture2D(s.FRAMEBUFFER,ot,K,ht,0);else throw new Error("THREE.WebGLTextures: Unknown depthTexture format.")}function Cn(P){let w=n.get(P),k=P.isWebGLCubeRenderTarget===!0;if(w.__boundDepthTexture!==P.depthTexture){let et=P.depthTexture;if(w.__depthDisposeCallback&&w.__depthDisposeCallback(),et){let $=()=>{delete w.__boundDepthTexture,delete w.__depthDisposeCallback,et.removeEventListener("dispose",$)};et.addEventListener("dispose",$),w.__depthDisposeCallback=$}w.__boundDepthTexture=et}if(P.depthTexture&&!w.__autoAllocateDepthBuffer)if(k)for(let et=0;et<6;et++)He(w.__webglFramebuffer[et],P,et);else P.texture.mipmaps.length>0?He(w.__webglFramebuffer[0],P,0):He(w.__webglFramebuffer,P,0);else if(k){w.__webglDepthbuffer=[];for(let et=0;et<6;et++)if(e.bindFramebuffer(s.FRAMEBUFFER,w.__webglFramebuffer[et]),w.__webglDepthbuffer[et]===void 0)w.__webglDepthbuffer[et]=s.createRenderbuffer(),Jn(w.__webglDepthbuffer[et],P,!1);else{let $=P.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,st=w.__webglDepthbuffer[et];s.bindRenderbuffer(s.RENDERBUFFER,st),s.framebufferRenderbuffer(s.FRAMEBUFFER,$,s.RENDERBUFFER,st)}}else if(P.texture.mipmaps.length>0?e.bindFramebuffer(s.FRAMEBUFFER,w.__webglFramebuffer[0]):e.bindFramebuffer(s.FRAMEBUFFER,w.__webglFramebuffer),w.__webglDepthbuffer===void 0)w.__webglDepthbuffer=s.createRenderbuffer(),Jn(w.__webglDepthbuffer,P,!1);else{let $=P.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,st=w.__webglDepthbuffer;s.bindRenderbuffer(s.RENDERBUFFER,st),s.framebufferRenderbuffer(s.FRAMEBUFFER,$,s.RENDERBUFFER,st)}e.bindFramebuffer(s.FRAMEBUFFER,null)}function Pn(P,w,k){let et=n.get(P);w!==void 0&&Se(et.__webglFramebuffer,P,P.texture,s.COLOR_ATTACHMENT0,s.TEXTURE_2D,0),k!==void 0&&Cn(P)}function In(P){let w=P.texture,k=n.get(P),et=n.get(w);P.addEventListener("dispose",C),I(P);let $=P.textures,st=P.isWebGLCubeRenderTarget===!0,ht=$.length>1;if(ht||(et.__webglTexture===void 0&&(et.__webglTexture=s.createTexture()),et.__version=w.version,o.memory.textures++),st){k.__webglFramebuffer=[];for(let Y=0;Y<6;Y++)if(w.mipmaps.length>0){k.__webglFramebuffer[Y]=[];for(let K=0;K<w.mipmaps.length;K++)k.__webglFramebuffer[Y][K]=s.createFramebuffer()}else k.__webglFramebuffer[Y]=s.createFramebuffer()}else{if(w.mipmaps.length>0){k.__webglFramebuffer=[];for(let Y=0;Y<w.mipmaps.length;Y++)k.__webglFramebuffer[Y]=s.createFramebuffer()}else k.__webglFramebuffer=s.createFramebuffer();if(ht)for(let Y=0,K=$.length;Y<K;Y++){let ot=n.get($[Y]);ot.__webglTexture===void 0&&(ot.__webglTexture=s.createTexture(),o.memory.textures++)}if(P.samples>0&&ft(P)===!1){k.__webglMultisampledFramebuffer=s.createFramebuffer(),k.__webglColorRenderbuffer=[],e.bindFramebuffer(s.FRAMEBUFFER,k.__webglMultisampledFramebuffer);for(let Y=0;Y<$.length;Y++){let K=$[Y];k.__webglColorRenderbuffer[Y]=s.createRenderbuffer(),s.bindRenderbuffer(s.RENDERBUFFER,k.__webglColorRenderbuffer[Y]);let ot=r.convert(K.format,K.colorSpace),D=r.convert(K.type),J=T(K.internalFormat,ot,D,K.normalized,K.colorSpace,P.isXRRenderTarget===!0),q=_e(P);s.renderbufferStorageMultisample(s.RENDERBUFFER,q,J,P.width,P.height),s.framebufferRenderbuffer(s.FRAMEBUFFER,s.COLOR_ATTACHMENT0+Y,s.RENDERBUFFER,k.__webglColorRenderbuffer[Y])}s.bindRenderbuffer(s.RENDERBUFFER,null),P.depthBuffer&&(k.__webglDepthRenderbuffer=s.createRenderbuffer(),Jn(k.__webglDepthRenderbuffer,P,!0)),e.bindFramebuffer(s.FRAMEBUFFER,null)}}if(st){e.bindTexture(s.TEXTURE_CUBE_MAP,et.__webglTexture),jt(s.TEXTURE_CUBE_MAP,w);for(let Y=0;Y<6;Y++)if(w.mipmaps.length>0)for(let K=0;K<w.mipmaps.length;K++)Se(k.__webglFramebuffer[Y][K],P,w,s.COLOR_ATTACHMENT0,s.TEXTURE_CUBE_MAP_POSITIVE_X+Y,K);else Se(k.__webglFramebuffer[Y],P,w,s.COLOR_ATTACHMENT0,s.TEXTURE_CUBE_MAP_POSITIVE_X+Y,0);M(w)?y(s.TEXTURE_CUBE_MAP):w.mipmaps.length>0&&s.texParameteri(s.TEXTURE_CUBE_MAP,s.TEXTURE_MAX_LEVEL,w.mipmaps.length-1),e.unbindTexture()}else if(ht){for(let Y=0,K=$.length;Y<K;Y++){let ot=$[Y],D=n.get(ot),J=s.TEXTURE_2D;(P.isWebGL3DRenderTarget||P.isWebGLArrayRenderTarget)&&(J=P.isWebGL3DRenderTarget?s.TEXTURE_3D:s.TEXTURE_2D_ARRAY),e.bindTexture(J,D.__webglTexture),jt(J,ot),Se(k.__webglFramebuffer,P,ot,s.COLOR_ATTACHMENT0+Y,J,0),M(ot)&&y(J)}e.unbindTexture()}else{let Y=s.TEXTURE_2D;if((P.isWebGL3DRenderTarget||P.isWebGLArrayRenderTarget)&&(Y=P.isWebGL3DRenderTarget?s.TEXTURE_3D:s.TEXTURE_2D_ARRAY),e.bindTexture(Y,et.__webglTexture),jt(Y,w),w.mipmaps.length>0)for(let K=0;K<w.mipmaps.length;K++)Se(k.__webglFramebuffer[K],P,w,s.COLOR_ATTACHMENT0,Y,K);else Se(k.__webglFramebuffer,P,w,s.COLOR_ATTACHMENT0,Y,0);M(w)?y(Y):w.mipmaps.length>0&&s.texParameteri(Y,s.TEXTURE_MAX_LEVEL,w.mipmaps.length-1),e.unbindTexture()}P.depthBuffer&&Cn(P)}function O(P){let w=P.textures;for(let k=0,et=w.length;k<et;k++){let $=w[k];if(M($)&&$.mipmapsAutoUpdate===!0){let st=S(P),ht=n.get($).__webglTexture;e.bindTexture(st,ht),y(st),e.unbindTexture()}}}let Ln=[];function ge(P){if(P.samples>0){if(ft(P)===!1){let w=P.textures,k=P.width,et=P.height,$=s.COLOR_BUFFER_BIT,st=P.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT,ht=n.get(P),Y=w.length>1;if(Y)for(let ot=0;ot<w.length;ot++)e.bindFramebuffer(s.FRAMEBUFFER,ht.__webglMultisampledFramebuffer),s.framebufferRenderbuffer(s.FRAMEBUFFER,s.COLOR_ATTACHMENT0+ot,s.RENDERBUFFER,null),e.bindFramebuffer(s.FRAMEBUFFER,ht.__webglFramebuffer),s.framebufferTexture2D(s.DRAW_FRAMEBUFFER,s.COLOR_ATTACHMENT0+ot,s.TEXTURE_2D,null,0);e.bindFramebuffer(s.READ_FRAMEBUFFER,ht.__webglMultisampledFramebuffer),P.texture.mipmaps.length>0?e.bindFramebuffer(s.DRAW_FRAMEBUFFER,ht.__webglFramebuffer[0]):e.bindFramebuffer(s.DRAW_FRAMEBUFFER,ht.__webglFramebuffer);for(let ot=0;ot<w.length;ot++){if(P.resolveDepthBuffer&&(P.depthBuffer&&($|=s.DEPTH_BUFFER_BIT),P.stencilBuffer&&P.resolveStencilBuffer&&($|=s.STENCIL_BUFFER_BIT)),Y){s.framebufferRenderbuffer(s.READ_FRAMEBUFFER,s.COLOR_ATTACHMENT0,s.RENDERBUFFER,ht.__webglColorRenderbuffer[ot]);let D=n.get(w[ot]).__webglTexture;s.framebufferTexture2D(s.DRAW_FRAMEBUFFER,s.COLOR_ATTACHMENT0,s.TEXTURE_2D,D,0)}s.blitFramebuffer(0,0,k,et,0,0,k,et,$,s.NEAREST),c===!0&&(Ln.length=0,Ln.push(s.COLOR_ATTACHMENT0+ot),P.depthBuffer&&P.storeMultisampledDepthBuffer===!1&&Ln.push(st),s.invalidateFramebuffer(s.READ_FRAMEBUFFER,Ln))}if(e.bindFramebuffer(s.READ_FRAMEBUFFER,null),e.bindFramebuffer(s.DRAW_FRAMEBUFFER,null),Y)for(let ot=0;ot<w.length;ot++){e.bindFramebuffer(s.FRAMEBUFFER,ht.__webglMultisampledFramebuffer),s.framebufferRenderbuffer(s.FRAMEBUFFER,s.COLOR_ATTACHMENT0+ot,s.RENDERBUFFER,ht.__webglColorRenderbuffer[ot]);let D=n.get(w[ot]).__webglTexture;e.bindFramebuffer(s.FRAMEBUFFER,ht.__webglFramebuffer),s.framebufferTexture2D(s.DRAW_FRAMEBUFFER,s.COLOR_ATTACHMENT0+ot,s.TEXTURE_2D,D,0)}e.bindFramebuffer(s.DRAW_FRAMEBUFFER,ht.__webglMultisampledFramebuffer)}else if(P.depthBuffer&&P.storeMultisampledDepthBuffer===!1&&c){let w=P.stencilBuffer?s.DEPTH_STENCIL_ATTACHMENT:s.DEPTH_ATTACHMENT;s.invalidateFramebuffer(s.DRAW_FRAMEBUFFER,[w])}}}function _e(P){return Math.min(i.maxSamples,P.samples)}function ft(P){let w=n.get(P);return P.samples>0&&t.has("WEBGL_multisampled_render_to_texture")===!0&&w.__useRenderToTexture!==!1}function ze(P){let w=o.render.frame;h.get(P)!==w&&(h.set(P,w),P.update())}function Lt(P,w){let k=P.colorSpace,et=P.format,$=P.type;return P.isCompressedTexture===!0||P.isVideoTexture===!0||k!==Ke&&k!==Ui&&(Ht.getTransfer(k)===se?(et!==Fn||$!==an)&&Tt("WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):Dt("WebGLTextures: Unsupported texture color space:",k)),w}function Bt(P){return typeof HTMLImageElement<"u"&&P instanceof HTMLImageElement?(l.width=P.naturalWidth||P.width,l.height=P.naturalHeight||P.height):typeof VideoFrame<"u"&&P instanceof VideoFrame?(l.width=P.displayWidth,l.height=P.displayHeight):(l.width=P.width,l.height=P.height),l}this.allocateTextureUnit=Ut,this.resetTextureUnits=j,this.getTextureUnits=Q,this.setTextureUnits=yt,this.setTexture2D=lt,this.setTexture2DArray=xt,this.setTexture3D=Ct,this.setTextureCube=dt,this.rebindTextures=Pn,this.setupRenderTarget=In,this.updateRenderTargetMipmap=O,this.updateMultisampleRenderTarget=ge,this.setupDepthRenderbuffer=Cn,this.setupFrameBufferTexture=Se,this.useMultisampledRTT=ft,this.dispose=B}function Sv(s,t){function e(n,i=Ui){let r,o=Ht.getTransfer(i);if(n===an)return s.UNSIGNED_BYTE;if(n===oc)return s.UNSIGNED_SHORT_4_4_4_4;if(n===ac)return s.UNSIGNED_SHORT_5_5_5_1;if(n===Ph)return s.UNSIGNED_INT_5_9_9_9_REV;if(n===Ih)return s.UNSIGNED_INT_10F_11F_11F_REV;if(n===Rh)return s.BYTE;if(n===Ch)return s.SHORT;if(n===Tr)return s.UNSIGNED_SHORT;if(n===rc)return s.INT;if(n===Yn)return s.UNSIGNED_INT;if(n===An)return s.FLOAT;if(n===cn)return s.HALF_FLOAT;if(n===Lh)return s.ALPHA;if(n===Nh)return s.RGB;if(n===Fn)return s.RGBA;if(n===bi)return s.DEPTH_COMPONENT;if(n===Di)return s.DEPTH_STENCIL;if(n===cc)return s.RED;if(n===lc)return s.RED_INTEGER;if(n===$i)return s.RG;if(n===hc)return s.RG_INTEGER;if(n===uc)return s.RGBA_INTEGER;if(n===No||n===Do||n===Uo||n===Fo)if(o===se)if(r=t.get("WEBGL_compressed_texture_s3tc_srgb"),r!==null){if(n===No)return r.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(n===Do)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(n===Uo)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(n===Fo)return r.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(r=t.get("WEBGL_compressed_texture_s3tc"),r!==null){if(n===No)return r.COMPRESSED_RGB_S3TC_DXT1_EXT;if(n===Do)return r.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(n===Uo)return r.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(n===Fo)return r.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(n===fc||n===dc||n===pc||n===mc)if(r=t.get("WEBGL_compressed_texture_pvrtc"),r!==null){if(n===fc)return r.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(n===dc)return r.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(n===pc)return r.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(n===mc)return r.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(n===gc||n===_c||n===xc||n===yc||n===vc||n===Oo||n===Mc)if(r=t.get("WEBGL_compressed_texture_etc"),r!==null){if(n===gc||n===_c)return o===se?r.COMPRESSED_SRGB8_ETC2:r.COMPRESSED_RGB8_ETC2;if(n===xc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:r.COMPRESSED_RGBA8_ETC2_EAC;if(n===yc)return r.COMPRESSED_R11_EAC;if(n===vc)return r.COMPRESSED_SIGNED_R11_EAC;if(n===Oo)return r.COMPRESSED_RG11_EAC;if(n===Mc)return r.COMPRESSED_SIGNED_RG11_EAC}else return null;if(n===Sc||n===bc||n===Tc||n===wc||n===Ac||n===Ec||n===Rc||n===Cc||n===Pc||n===Ic||n===Lc||n===Nc||n===Dc||n===Uc)if(r=t.get("WEBGL_compressed_texture_astc"),r!==null){if(n===Sc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:r.COMPRESSED_RGBA_ASTC_4x4_KHR;if(n===bc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:r.COMPRESSED_RGBA_ASTC_5x4_KHR;if(n===Tc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:r.COMPRESSED_RGBA_ASTC_5x5_KHR;if(n===wc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:r.COMPRESSED_RGBA_ASTC_6x5_KHR;if(n===Ac)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:r.COMPRESSED_RGBA_ASTC_6x6_KHR;if(n===Ec)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:r.COMPRESSED_RGBA_ASTC_8x5_KHR;if(n===Rc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:r.COMPRESSED_RGBA_ASTC_8x6_KHR;if(n===Cc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:r.COMPRESSED_RGBA_ASTC_8x8_KHR;if(n===Pc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:r.COMPRESSED_RGBA_ASTC_10x5_KHR;if(n===Ic)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:r.COMPRESSED_RGBA_ASTC_10x6_KHR;if(n===Lc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:r.COMPRESSED_RGBA_ASTC_10x8_KHR;if(n===Nc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:r.COMPRESSED_RGBA_ASTC_10x10_KHR;if(n===Dc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:r.COMPRESSED_RGBA_ASTC_12x10_KHR;if(n===Uc)return o===se?r.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:r.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(n===Fc||n===Oc||n===Bc)if(r=t.get("EXT_texture_compression_bptc"),r!==null){if(n===Fc)return o===se?r.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:r.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(n===Oc)return r.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(n===Bc)return r.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(n===zc||n===kc||n===Bo||n===Vc)if(r=t.get("EXT_texture_compression_rgtc"),r!==null){if(n===zc)return r.COMPRESSED_RED_RGTC1_EXT;if(n===kc)return r.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(n===Bo)return r.COMPRESSED_RED_GREEN_RGTC2_EXT;if(n===Vc)return r.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return n===Rs?s.UNSIGNED_INT_24_8:s[n]!==void 0?s[n]:null}return{convert:e}}var bv=`
void main() {

	gl_Position = vec4( position, 1.0 );

}`,Tv=`
uniform sampler2DArray depthColor;
uniform float depthWidth;
uniform float depthHeight;

void main() {

	vec2 coord = vec2( gl_FragCoord.x / depthWidth, gl_FragCoord.y / depthHeight );

	if ( coord.x >= 1.0 ) {

		gl_FragDepth = texture( depthColor, vec3( coord.x - 1.0, coord.y, 1 ) ).r;

	} else {

		gl_FragDepth = texture( depthColor, vec3( coord.x, coord.y, 0 ) ).r;

	}

}`,au=class{constructor(){this.texture=null,this.mesh=null,this.depthNear=0,this.depthFar=0}init(t,e){if(this.texture===null){let n=new _o(t.texture);(t.depthNear!==e.depthNear||t.depthFar!==e.depthFar)&&(this.depthNear=t.depthNear,this.depthFar=t.depthFar),this.texture=n}}getMesh(t){if(this.texture!==null&&this.mesh===null){let e=t.cameras[0].viewport,n=new ei({vertexShader:bv,fragmentShader:Tv,uniforms:{depthColor:{value:this.texture},depthWidth:{value:e.z},depthHeight:{value:e.w}}});this.mesh=new Ee(new Ri(20,20),n)}return this.mesh}reset(){this.texture=null,this.mesh=null}getDepthTexture(){return this.texture}},cu=class extends Qn{constructor(t,e){super();let n=this,i=null,r=1,o=null,a="local-floor",c=1,l=null,h=null,f=null,u=null,d=null,g=null,v=typeof XRWebGLBinding<"u",m=new au,p={},x=e.getContextAttributes(),M=null,y=null,S=[],T=[],_=new At,b=null,I=null,E=new Le;E.viewport=new Zt;let L=new Le;L.viewport=new Zt;let C=[E,L],U=new ec,N=null,B=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(Z){let lt=S[Z];return lt===void 0&&(lt=new ar,S[Z]=lt),lt.getTargetRaySpace()},this.getControllerGrip=function(Z){let lt=S[Z];return lt===void 0&&(lt=new ar,S[Z]=lt),lt.getGripSpace()},this.getHand=function(Z){let lt=S[Z];return lt===void 0&&(lt=new ar,S[Z]=lt),lt.getHandSpace()};function G(Z){let lt=T.indexOf(Z.inputSource);if(lt===-1)return;let xt=S[lt];xt!==void 0&&(xt.update(Z.inputSource,Z.frame,l||o),xt.dispatchEvent({type:Z.type,data:Z.inputSource}))}function H(){i.removeEventListener("select",G),i.removeEventListener("selectstart",G),i.removeEventListener("selectend",G),i.removeEventListener("squeeze",G),i.removeEventListener("squeezestart",G),i.removeEventListener("squeezeend",G),i.removeEventListener("end",H),i.removeEventListener("inputsourceschange",tt);for(let Z=0;Z<S.length;Z++){let lt=T[Z];lt!==null&&(T[Z]=null,S[Z].disconnect(lt))}N=null,B=null,m.reset();for(let Z in p)delete p[Z];if(t.setRenderTarget(M),d=null,u=null,f=null,i=null,y=null,Ut.stop(),n.isPresenting=!1,t.setPixelRatio(b),t.setSize(_.width,_.height,!1),I!==null){let Z=I.camera;Z.fov=I.fov,Z.zoom=I.zoom,Z.updateProjectionMatrix(),I=null}n.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(Z){r=Z,n.isPresenting===!0&&Tt("WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(Z){a=Z,n.isPresenting===!0&&Tt("WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return l||o},this.setReferenceSpace=function(Z){l=Z},this.getBaseLayer=function(){return u!==null?u:d},this.getBinding=function(){return f===null&&v&&(f=new XRWebGLBinding(i,e)),f},this.getFrame=function(){return g},this.getSession=function(){return i},this.setSession=async function(Z){if(i=Z,i!==null){if(M=t.getRenderTarget(),i.addEventListener("select",G),i.addEventListener("selectstart",G),i.addEventListener("selectend",G),i.addEventListener("squeeze",G),i.addEventListener("squeezestart",G),i.addEventListener("squeezeend",G),i.addEventListener("end",H),i.addEventListener("inputsourceschange",tt),x.xrCompatible!==!0&&await e.makeXRCompatible(),b=t.getPixelRatio(),t.getSize(_),v&&"createProjectionLayer"in XRWebGLBinding.prototype){let xt=null,Ct=null,dt=null;x.depth&&(dt=x.stencil?e.DEPTH24_STENCIL8:e.DEPTH_COMPONENT24,xt=x.stencil?Di:bi,Ct=x.stencil?Rs:Yn);let Ot={colorFormat:e.RGBA8,depthFormat:dt,scaleFactor:r};f=this.getBinding(),u=f.createProjectionLayer(Ot),i.updateRenderState({layers:[u]}),t.setPixelRatio(1),t.setSize(u.textureWidth,u.textureHeight,!1),y=new je(u.textureWidth,u.textureHeight,{format:Fn,type:an,depthTexture:new Ei(u.textureWidth,u.textureHeight,Ct,void 0,void 0,void 0,void 0,void 0,void 0,xt),stencilBuffer:x.stencil,colorSpace:t.outputColorSpace,samples:x.antialias?4:0,resolveDepthBuffer:u.ignoreDepthValues===!1,resolveStencilBuffer:u.ignoreDepthValues===!1,storeMultisampledDepthBuffer:u.ignoreDepthValues===!1,storeMultisampledStencilBuffer:u.ignoreDepthValues===!1})}else{let xt={antialias:x.antialias,alpha:!0,depth:x.depth,stencil:x.stencil,framebufferScaleFactor:r};d=new XRWebGLLayer(i,e,xt),i.updateRenderState({baseLayer:d}),t.setPixelRatio(1),t.setSize(d.framebufferWidth,d.framebufferHeight,!1),y=new je(d.framebufferWidth,d.framebufferHeight,{format:Fn,type:an,colorSpace:t.outputColorSpace,stencilBuffer:x.stencil,resolveDepthBuffer:d.ignoreDepthValues===!1,resolveStencilBuffer:d.ignoreDepthValues===!1,storeMultisampledDepthBuffer:d.ignoreDepthValues===!1,storeMultisampledStencilBuffer:d.ignoreDepthValues===!1})}y.isXRRenderTarget=!0,this.setFoveation(c),l=null,o=await i.requestReferenceSpace(a),Ut.setContext(i),Ut.start(),n.isPresenting=!0,n.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(i!==null)return i.environmentBlendMode},this.getDepthTexture=function(){return m.getDepthTexture()};function tt(Z){for(let lt=0;lt<Z.removed.length;lt++){let xt=Z.removed[lt],Ct=T.indexOf(xt);Ct>=0&&(T[Ct]=null,S[Ct].disconnect(xt))}for(let lt=0;lt<Z.added.length;lt++){let xt=Z.added[lt],Ct=T.indexOf(xt);if(Ct===-1){for(let Ot=0;Ot<S.length;Ot++)if(Ot>=T.length){T.push(xt),Ct=Ot;break}else if(T[Ot]===null){T[Ot]=xt,Ct=Ot;break}if(Ct===-1)break}let dt=S[Ct];dt&&dt.connect(xt)}}function X(Z,lt){lt===null?Z.matrixWorld.copy(Z.matrix):Z.matrixWorld.multiplyMatrices(lt.matrixWorld,Z.matrix),Z.matrixWorldInverse.copy(Z.matrixWorld).invert()}this.updateCamera=function(Z){if(i===null)return;let lt=Z.near,xt=Z.far;m.texture!==null&&(m.depthNear>0&&(lt=m.depthNear),m.depthFar>0&&(xt=m.depthFar)),U.near=L.near=E.near=lt,U.far=L.far=E.far=xt,(N!==U.near||B!==U.far)&&(i.updateRenderState({depthNear:U.near,depthFar:U.far}),N=U.near,B=U.far),U.layers.mask=Z.layers.mask|6,E.layers.mask=U.layers.mask&-5,L.layers.mask=U.layers.mask&-3;let Ct=Z.parent,dt=U.cameras;X(U,Ct);for(let Ot=0;Ot<dt.length;Ot++)X(dt[Ot],Ct);U.projectionMatrix.copy(E.projectionMatrix),U.projectionMatrixInverse.copy(E.projectionMatrixInverse),I===null&&Z.isPerspectiveCamera&&(I={camera:Z,fov:Z.fov,zoom:Z.zoom}),j(Z,U,Ct)};function j(Z,lt,xt){xt===null?Z.matrix.copy(lt.matrixWorld):(Z.matrix.copy(xt.matrixWorld),Z.matrix.invert(),Z.matrix.multiply(lt.matrixWorld)),Z.matrix.decompose(Z.position,Z.quaternion,Z.scale),Z.updateMatrixWorld(!0),Z.projectionMatrix.copy(lt.projectionMatrix),Z.projectionMatrixInverse.copy(lt.projectionMatrixInverse),Z.isPerspectiveCamera&&(Z.fov=_s*2*Math.atan(1/Z.projectionMatrix.elements[5]),Z.zoom=1)}this.getCamera=function(){return U},this.getFoveation=function(){if(!(u===null&&d===null))return c},this.setFoveation=function(Z){c=Z,u!==null&&(u.fixedFoveation=Z),d!==null&&d.fixedFoveation!==void 0&&(d.fixedFoveation=Z)},this.hasDepthSensing=function(){return m.texture!==null},this.getDepthSensingMesh=function(){return m.getMesh(U)},this.getCameraTexture=function(Z){return p[Z]};let Q=null;function yt(Z,lt){if(h=lt.getViewerPose(l||o),g=lt,h!==null){let xt=h.views;d!==null&&(t.setRenderTargetFramebuffer(y,d.framebuffer),t.setRenderTarget(y));let Ct=!1;xt.length!==U.cameras.length&&(U.cameras.length=0,Ct=!0);for(let It=0;It<xt.length;It++){let jt=xt[It],le=null;if(d!==null)le=d.getViewport(jt);else{let Ze=f.getViewSubImage(u,jt);le=Ze.viewport,It===0&&(t.setRenderTargetTextures(y,Ze.colorTexture,Ze.depthStencilTexture),t.setRenderTarget(y))}let qt=C[It];qt===void 0&&(qt=new Le,qt.layers.enable(It),qt.viewport=new Zt,C[It]=qt),qt.matrix.fromArray(jt.transform.matrix),qt.matrix.decompose(qt.position,qt.quaternion,qt.scale),qt.projectionMatrix.fromArray(jt.projectionMatrix),qt.projectionMatrixInverse.copy(qt.projectionMatrix).invert(),qt.viewport.set(le.x,le.y,le.width,le.height),It===0&&(U.matrix.copy(qt.matrix),U.matrix.decompose(U.position,U.quaternion,U.scale)),Ct===!0&&U.cameras.push(qt)}let dt=i.enabledFeatures;if(dt&&dt.includes("depth-sensing")&&i.depthUsage=="gpu-optimized"&&v){f=n.getBinding();let It=f.getDepthInformation(xt[0]);It&&It.isValid&&It.texture&&m.init(It,i.renderState)}if(dt&&dt.includes("camera-access")&&v){t.state.unbindTexture(),f=n.getBinding();for(let It=0;It<xt.length;It++){let jt=xt[It].camera;if(jt){let le=p[jt];le||(le=new _o,p[jt]=le);let qt=f.getCameraImage(jt);le.sourceTexture=qt}}}}for(let xt=0;xt<S.length;xt++){let Ct=T[xt],dt=S[xt];Ct!==null&&dt!==void 0&&dt.update(Ct,lt,l||o)}Q&&Q(Z,lt),lt.detectedPlanes&&n.dispatchEvent({type:"planesdetected",data:lt}),g=null}let Ut=new Sp;Ut.setAnimationLoop(yt),this.setAnimationLoop=function(Z){Q=Z},this.dispose=function(){}}},wv=new _t,Lp=new Ft;Lp.set(-1,0,0,0,1,0,0,0,1);function Av(s,t){function e(m,p){m.matrixAutoUpdate===!0&&m.updateMatrix(),p.value.copy(m.matrix)}function n(m,p){p.color.getRGB(m.fogColor.value,Wh(s)),p.isFog?(m.fogNear.value=p.near,m.fogFar.value=p.far):p.isFogExp2&&(m.fogDensity.value=p.density)}function i(m,p,x,M,y){p.isNodeMaterial?p.uniformsNeedUpdate=!1:p.isMeshBasicMaterial?r(m,p):p.isMeshLambertMaterial?(r(m,p),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)):p.isMeshToonMaterial?(r(m,p),f(m,p)):p.isMeshPhongMaterial?(r(m,p),h(m,p),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)):p.isMeshStandardMaterial?(r(m,p),u(m,p),p.isMeshPhysicalMaterial&&d(m,p,y)):p.isMeshMatcapMaterial?(r(m,p),g(m,p)):p.isMeshDepthMaterial?r(m,p):p.isMeshDistanceMaterial?(r(m,p),v(m,p)):p.isMeshNormalMaterial?r(m,p):p.isLineBasicMaterial?(o(m,p),p.isLineDashedMaterial&&a(m,p)):p.isPointsMaterial?c(m,p,x,M):p.isSpriteMaterial?l(m,p):p.isShadowMaterial?(m.color.value.copy(p.color),m.opacity.value=p.opacity):p.isShaderMaterial&&(p.uniformsNeedUpdate=!1)}function r(m,p){m.opacity.value=p.opacity,p.color&&m.diffuse.value.copy(p.color),p.emissive&&m.emissive.value.copy(p.emissive).multiplyScalar(p.emissiveIntensity),p.map&&(m.map.value=p.map,e(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,e(p.alphaMap,m.alphaMapTransform)),p.bumpMap&&(m.bumpMap.value=p.bumpMap,e(p.bumpMap,m.bumpMapTransform),m.bumpScale.value=p.bumpScale,p.side===Ne&&(m.bumpScale.value*=-1)),p.normalMap&&(m.normalMap.value=p.normalMap,e(p.normalMap,m.normalMapTransform),m.normalScale.value.copy(p.normalScale),p.side===Ne&&m.normalScale.value.negate()),p.displacementMap&&(m.displacementMap.value=p.displacementMap,e(p.displacementMap,m.displacementMapTransform),m.displacementScale.value=p.displacementScale,m.displacementBias.value=p.displacementBias),p.emissiveMap&&(m.emissiveMap.value=p.emissiveMap,e(p.emissiveMap,m.emissiveMapTransform)),p.specularMap&&(m.specularMap.value=p.specularMap,e(p.specularMap,m.specularMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest);let x=t.get(p),M=x.envMap,y=x.envMapRotation;M&&(m.envMap.value=M,m.envMapRotation.value.setFromMatrix4(wv.makeRotationFromEuler(y)).transpose(),M.isCubeTexture&&M.isRenderTargetTexture===!1&&m.envMapRotation.value.premultiply(Lp),m.reflectivity.value=p.reflectivity,m.ior.value=p.ior,m.refractionRatio.value=p.refractionRatio),p.lightMap&&(m.lightMap.value=p.lightMap,m.lightMapIntensity.value=p.lightMapIntensity,e(p.lightMap,m.lightMapTransform)),p.aoMap&&(m.aoMap.value=p.aoMap,m.aoMapIntensity.value=p.aoMapIntensity,e(p.aoMap,m.aoMapTransform))}function o(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,p.map&&(m.map.value=p.map,e(p.map,m.mapTransform))}function a(m,p){m.dashSize.value=p.dashSize,m.totalSize.value=p.dashSize+p.gapSize,m.scale.value=p.scale}function c(m,p,x,M){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.size.value=p.size*x,m.scale.value=M*.5,p.map&&(m.map.value=p.map,e(p.map,m.uvTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,e(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function l(m,p){m.diffuse.value.copy(p.color),m.opacity.value=p.opacity,m.rotation.value=p.rotation,p.map&&(m.map.value=p.map,e(p.map,m.mapTransform)),p.alphaMap&&(m.alphaMap.value=p.alphaMap,e(p.alphaMap,m.alphaMapTransform)),p.alphaTest>0&&(m.alphaTest.value=p.alphaTest)}function h(m,p){m.specular.value.copy(p.specular),m.shininess.value=Math.max(p.shininess,1e-4)}function f(m,p){p.gradientMap&&(m.gradientMap.value=p.gradientMap)}function u(m,p){m.metalness.value=p.metalness,p.metalnessMap&&(m.metalnessMap.value=p.metalnessMap,e(p.metalnessMap,m.metalnessMapTransform)),m.roughness.value=p.roughness,p.roughnessMap&&(m.roughnessMap.value=p.roughnessMap,e(p.roughnessMap,m.roughnessMapTransform)),p.envMap&&(m.envMapIntensity.value=p.envMapIntensity)}function d(m,p,x){m.ior.value=p.ior,p.diffuseRoughness>0&&(m.diffuseRoughness.value=p.diffuseRoughness,p.diffuseRoughnessMap&&(m.diffuseRoughnessMap.value=p.diffuseRoughnessMap,e(p.diffuseRoughnessMap,m.diffuseRoughnessMapTransform))),p.sheen>0&&(m.sheenColor.value.copy(p.sheenColor).multiplyScalar(p.sheen),m.sheenRoughness.value=p.sheenRoughness,p.sheenColorMap&&(m.sheenColorMap.value=p.sheenColorMap,e(p.sheenColorMap,m.sheenColorMapTransform)),p.sheenRoughnessMap&&(m.sheenRoughnessMap.value=p.sheenRoughnessMap,e(p.sheenRoughnessMap,m.sheenRoughnessMapTransform))),p.clearcoat>0&&(m.clearcoat.value=p.clearcoat,m.clearcoatRoughness.value=p.clearcoatRoughness,p.clearcoatMap&&(m.clearcoatMap.value=p.clearcoatMap,e(p.clearcoatMap,m.clearcoatMapTransform)),p.clearcoatRoughnessMap&&(m.clearcoatRoughnessMap.value=p.clearcoatRoughnessMap,e(p.clearcoatRoughnessMap,m.clearcoatRoughnessMapTransform)),p.clearcoatNormalMap&&(m.clearcoatNormalMap.value=p.clearcoatNormalMap,e(p.clearcoatNormalMap,m.clearcoatNormalMapTransform),m.clearcoatNormalScale.value.copy(p.clearcoatNormalScale),p.side===Ne&&m.clearcoatNormalScale.value.negate())),p.dispersion>0&&(m.dispersion.value=p.dispersion),p.retroreflectivity>0&&(m.retroreflectivity.value=p.retroreflectivity),p.iridescence>0&&(m.iridescence.value=p.iridescence,m.iridescenceIOR.value=p.iridescenceIOR,m.iridescenceThicknessMinimum.value=p.iridescenceThicknessMinimum,m.iridescenceThicknessMaximum.value=p.iridescenceThicknessMaximum,p.iridescenceMap&&(m.iridescenceMap.value=p.iridescenceMap,e(p.iridescenceMap,m.iridescenceMapTransform)),p.iridescenceThicknessMap&&(m.iridescenceThicknessMap.value=p.iridescenceThicknessMap,e(p.iridescenceThicknessMap,m.iridescenceThicknessMapTransform))),p.transmission>0&&(m.transmission.value=p.transmission,m.transmissionSamplerMap.value=x.texture,m.transmissionSamplerSize.value.set(x.width,x.height),p.transmissionMap&&(m.transmissionMap.value=p.transmissionMap,e(p.transmissionMap,m.transmissionMapTransform)),m.thickness.value=p.thickness,p.thicknessMap&&(m.thicknessMap.value=p.thicknessMap,e(p.thicknessMap,m.thicknessMapTransform)),m.attenuationDistance.value=p.attenuationDistance,m.attenuationColor.value.copy(p.attenuationColor)),p.anisotropy>0&&(m.anisotropyVector.value.set(p.anisotropy*Math.cos(p.anisotropyRotation),p.anisotropy*Math.sin(p.anisotropyRotation)),p.anisotropyMap&&(m.anisotropyMap.value=p.anisotropyMap,e(p.anisotropyMap,m.anisotropyMapTransform))),m.specularIntensity.value=p.specularIntensity,m.specularColor.value.copy(p.specularColor),p.specularColorMap&&(m.specularColorMap.value=p.specularColorMap,e(p.specularColorMap,m.specularColorMapTransform)),p.specularIntensityMap&&(m.specularIntensityMap.value=p.specularIntensityMap,e(p.specularIntensityMap,m.specularIntensityMapTransform))}function g(m,p){p.matcap&&(m.matcap.value=p.matcap)}function v(m,p){let x=t.get(p).light;m.referencePosition.value.setFromMatrixPosition(x.matrixWorld),m.nearDistance.value=x.shadow.camera.near,m.farDistance.value=x.shadow.camera.far}return{refreshFogUniforms:n,refreshMaterialUniforms:i}}function Ev(s,t,e,n){let i={},r={};function o(x,M){let y=M.program;n.uniformBlockBinding(x,y,i[x.id])}function a(x,M){let y=i[x.id];y===void 0&&(g(x),y=c(x),i[x.id]=y,x.addEventListener("dispose",m));let S=M.program;n.updateUBOMapping(x,S);let T=t.render.frame;r[x.id]!==T&&(l(x),r[x.id]=T)}function c(x){let M=s.createBuffer(),y=x.__size,S=x.usage;return s.bindBuffer(s.UNIFORM_BUFFER,M),s.bufferData(s.UNIFORM_BUFFER,y,S),s.bindBuffer(s.UNIFORM_BUFFER,null),M}function l(x){let M=i[x.id],y=x.uniforms,S=x.__cache;s.bindBuffer(s.UNIFORM_BUFFER,M);for(let T=0,_=y.length;T<_;T++){let b=y[T];if(Array.isArray(b))for(let I=0,E=b.length;I<E;I++)h(b[I],T,I,S);else h(b,T,0,S)}s.bindBuffer(s.UNIFORM_BUFFER,null)}function h(x,M,y,S){if(u(x,M,y,S)===!0){let T=x.__offset,_=x.value;if(Array.isArray(_)){let b=0;for(let I=0;I<_.length;I++){let E=_[I],L=v(E,!0);f(E,x.__data,b),b+=L.storage/Float32Array.BYTES_PER_ELEMENT}}else f(_,x.__data,0);s.bufferSubData(s.UNIFORM_BUFFER,T,x.__data)}}function f(x,M,y){typeof x=="number"||typeof x=="boolean"?M[y]=x:x.isMatrix3?(M[y]=x.elements[0],M[y+1]=x.elements[1],M[y+2]=x.elements[2],M[y+3]=0,M[y+4]=x.elements[3],M[y+5]=x.elements[4],M[y+6]=x.elements[5],M[y+7]=0,M[y+8]=x.elements[6],M[y+9]=x.elements[7],M[y+10]=x.elements[8],M[y+11]=0):ArrayBuffer.isView(x)?M.set(x.subarray(0,M.length-y),y):x.toArray(M,y)}function u(x,M,y,S){let T=x.value,_=M+"_"+y;if(Array.isArray(T)){S[_]===void 0&&(S[_]=[]);let b=S[_],I=!1;for(let E=0;E<T.length;E++)d(T[E],b,E)===!0&&(I=!0);return I}return d(T,S,_)}function d(x,M,y){if(M[y]===void 0)return typeof x=="number"||typeof x=="boolean"?M[y]=x:ArrayBuffer.isView(x)?M[y]=x.slice():M[y]=x.clone(),!0;{let S=M[y];if(typeof x=="number"||typeof x=="boolean"){if(S!==x)return M[y]=x,!0}else{if(ArrayBuffer.isView(x))return!0;if(S.equals(x)===!1)return S.copy(x),!0}}return!1}function g(x){let M=x.uniforms,y=0,S=16;for(let _=0,b=M.length;_<b;_++){let I=Array.isArray(M[_])?M[_]:[M[_]];for(let E=0,L=I.length;E<L;E++){let C=I[E],U=Array.isArray(C.value)?C.value:[C.value],N=Array.isArray(M[_])||Array.isArray(C.value),B=y;for(let H=0,tt=U.length;H<tt;H++){let X=U[H],j=v(X,N),Q=y%S,yt=Q%j.boundary,Ut=Q+yt;y+=yt,Ut!==0&&S-Ut<j.storage&&(y+=S-Ut),H===0&&(B=y),y+=j.storage}let G=C.type==="int"?Int32Array:C.type==="uint"?Uint32Array:Float32Array;C.__data=new G((y-B)/Float32Array.BYTES_PER_ELEMENT),C.__offset=B}}let T=y%S;return T>0&&(y+=S-T),x.__size=y,x.__cache={},this}function v(x,M){let y={boundary:0,storage:0};return typeof x=="number"||typeof x=="boolean"?(y.boundary=4,y.storage=4):x.isVector2?(y.boundary=8,y.storage=8):x.isVector3||x.isColor?(y.boundary=16,y.storage=12):x.isVector4?(y.boundary=16,y.storage=16):x.isMatrix3?(y.boundary=16,y.storage=48):x.isMatrix4?(y.boundary=16,y.storage=64):x.isTexture?Tt("WebGLRenderer: Texture samplers can not be part of an uniforms group."):ArrayBuffer.isView(x)?(y.boundary=16,y.storage=x.byteLength):Tt("WebGLRenderer: Unsupported uniform value type.",x),M===!0&&(y.boundary=16,y.storage=Math.ceil(y.storage/16)*16),y}function m(x){let M=x.target;M.removeEventListener("dispose",m),s.deleteBuffer(i[M.id]),delete i[M.id],delete r[M.id]}function p(){for(let x in i)s.deleteBuffer(i[x]);i={},r={}}return{bind:o,update:a,dispose:p}}var Rv=new Uint16Array([12469,15057,12620,14925,13266,14620,13807,14376,14323,13990,14545,13625,14713,13328,14840,12882,14931,12528,14996,12233,15039,11829,15066,11525,15080,11295,15085,10976,15082,10705,15073,10495,13880,14564,13898,14542,13977,14430,14158,14124,14393,13732,14556,13410,14702,12996,14814,12596,14891,12291,14937,11834,14957,11489,14958,11194,14943,10803,14921,10506,14893,10278,14858,9960,14484,14039,14487,14025,14499,13941,14524,13740,14574,13468,14654,13106,14743,12678,14818,12344,14867,11893,14889,11509,14893,11180,14881,10751,14852,10428,14812,10128,14765,9754,14712,9466,14764,13480,14764,13475,14766,13440,14766,13347,14769,13070,14786,12713,14816,12387,14844,11957,14860,11549,14868,11215,14855,10751,14825,10403,14782,10044,14729,9651,14666,9352,14599,9029,14967,12835,14966,12831,14963,12804,14954,12723,14936,12564,14917,12347,14900,11958,14886,11569,14878,11247,14859,10765,14828,10401,14784,10011,14727,9600,14660,9289,14586,8893,14508,8533,15111,12234,15110,12234,15104,12216,15092,12156,15067,12010,15028,11776,14981,11500,14942,11205,14902,10752,14861,10393,14812,9991,14752,9570,14682,9252,14603,8808,14519,8445,14431,8145,15209,11449,15208,11451,15202,11451,15190,11438,15163,11384,15117,11274,15055,10979,14994,10648,14932,10343,14871,9936,14803,9532,14729,9218,14645,8742,14556,8381,14461,8020,14365,7603,15273,10603,15272,10607,15267,10619,15256,10631,15231,10614,15182,10535,15118,10389,15042,10167,14963,9787,14883,9447,14800,9115,14710,8665,14615,8318,14514,7911,14411,7507,14279,7198,15314,9675,15313,9683,15309,9712,15298,9759,15277,9797,15229,9773,15166,9668,15084,9487,14995,9274,14898,8910,14800,8539,14697,8234,14590,7790,14479,7409,14367,7067,14178,6621,15337,8619,15337,8631,15333,8677,15325,8769,15305,8871,15264,8940,15202,8909,15119,8775,15022,8565,14916,8328,14804,8009,14688,7614,14569,7287,14448,6888,14321,6483,14088,6171,15350,7402,15350,7419,15347,7480,15340,7613,15322,7804,15287,7973,15229,8057,15148,8012,15046,7846,14933,7611,14810,7357,14682,7069,14552,6656,14421,6316,14251,5948,14007,5528,15356,5942,15356,5977,15353,6119,15348,6294,15332,6551,15302,6824,15249,7044,15171,7122,15070,7050,14949,6861,14818,6611,14679,6349,14538,6067,14398,5651,14189,5311,13935,4958,15359,4123,15359,4153,15356,4296,15353,4646,15338,5160,15311,5508,15263,5829,15188,6042,15088,6094,14966,6001,14826,5796,14678,5543,14527,5287,14377,4985,14133,4586,13869,4257,15360,1563,15360,1642,15358,2076,15354,2636,15341,3350,15317,4019,15273,4429,15203,4732,15105,4911,14981,4932,14836,4818,14679,4621,14517,4386,14359,4156,14083,3795,13808,3437,15360,122,15360,137,15358,285,15355,636,15344,1274,15322,2177,15281,2765,15215,3223,15120,3451,14995,3569,14846,3567,14681,3466,14511,3305,14344,3121,14037,2800,13753,2467,15360,0,15360,1,15359,21,15355,89,15346,253,15325,479,15287,796,15225,1148,15133,1492,15008,1749,14856,1882,14685,1886,14506,1783,14324,1608,13996,1398,13702,1183]),ai=null;function Cv(){return ai===null&&(ai=new ur(Rv,16,16,$i,cn),ai.name="DFG_LUT",ai.minFilter=we,ai.magFilter=we,ai.wrapS=xn,ai.wrapT=xn,ai.generateMipmaps=!1,ai.needsUpdate=!0),ai}var qc=class{constructor(t={}){let{canvas:e=Yd(),context:n=null,depth:i=!0,stencil:r=!1,alpha:o=!1,antialias:a=!1,premultipliedAlpha:c=!0,preserveDrawingBuffer:l=!1,powerPreference:h="default",failIfMajorPerformanceCaveat:f=!1,reversedDepthBuffer:u=!1,outputBufferType:d=an}=t;this.isWebGLRenderer=!0;let g;if(n!==null){if(typeof WebGLRenderingContext<"u"&&n instanceof WebGLRenderingContext)throw new Error("THREE.WebGLRenderer: WebGL 1 is not supported since r163.");g=n.getContextAttributes().alpha}else g=o;let v=d,m=new Set([uc,hc,lc]),p=new Set([an,Yn,Tr,Rs,oc,ac]),x=new Uint32Array(4),M=new Int32Array(4),y={textures:[],min:[],max:[],resolution:[]},S=null,T=null,_=[],b=[],I=null;this.domElement=e,this.debug={checkShaderErrors:!0,diagnostics:{keywords:!1},onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this.toneMapping=ri,this.toneMappingExposure=1,this.transmissionResolutionScale=1;let E=this,L=!1,C=null,U=null,N=null,B=null;this._outputColorSpace=ee;let G=0,H=0,tt=null,X=-1,j=null,Q=new Zt,yt=new Zt,Ut=null,Z=new Pt(0),lt=0,xt=e.width,Ct=e.height,dt=1,Ot=null,Ce=null,It=new Zt(0,0,xt,Ct),jt=new Zt(0,0,xt,Ct),le=!1,qt=new Ki,Ze=new Ha,Be=!1,_n=!1,Se=new _t,Jn=new R,He=new Zt,Cn={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0},Pn=!1;function In(){return tt===null?dt:1}let O=n;function Ln(A,F){return e.getContext(A,F)}let ge,_e,ft,ze,Lt,Bt,P,w,k,et,$,st,ht,Y,K,ot,D,J,q,at,it,rt,wt;try{let A={alpha:!0,depth:i,stencil:r,antialias:a,premultipliedAlpha:c,preserveDrawingBuffer:l,powerPreference:h,failIfMajorPerformanceCaveat:f};if("setAttribute"in e&&e.setAttribute("data-engine",`three.js r${"187"}`),e.addEventListener("webglcontextlost",Rt,!1),e.addEventListener("webglcontextrestored",Vt,!1),e.addEventListener("webglcontextcreationerror",pt,!1),O===null){let F="webgl2";if(O=Ln(F,A),O===null)throw Ln(F)?new Error("THREE.WebGLRenderer: Error creating WebGL context with your selected attributes."):new Error("THREE.WebGLRenderer: Error creating WebGL context.")}Gt()}catch(A){throw e.removeEventListener("webglcontextlost",Rt,!1),e.removeEventListener("webglcontextrestored",Vt,!1),e.removeEventListener("webglcontextcreationerror",pt,!1),Dt("WebGLRenderer: "+A.message),A}function Gt(){ge=new kx(O),ge.init(),it=new Sv(O,ge),_e=new Cx(O,ge,t,it),ft=new vv(O,ge),_e.reversedDepthBuffer&&u&&ft.buffers.depth.setReversed(!0),U=O.createFramebuffer(),N=O.createFramebuffer(),B=O.createFramebuffer(),ze=new Hx(O),Lt=new ov,Bt=new Mv(O,ge,ft,Lt,_e,it,ze),P=new zx(E),w=new Xg(O),rt=new Ex(O,w),k=new Vx(O,w,ze,rt),et=new Xx(O,k,w,rt,ze),J=new Wx(O,_e,Bt),K=new Px(Lt),$=new rv(E,P,ge,_e,rt,K),st=new Av(E,Lt),ht=new cv,Y=new pv(ge),D=new Ax(E,P,ft,et,g,c),ot=new yv(E,et,_e),wt=new Ev(O,ze,_e,ft),q=new Rx(O,ge,ze),at=new Gx(O,ge,ze),ze.programs=$.programs,E.capabilities=_e,E.extensions=ge,E.properties=Lt,E.renderLists=ht,E.shadowMap=ot,E.state=ft,E.info=ze}v!==an&&(I=new Yx(v,e.width,e.height,a,i,r));let nt=new cu(E,O);this.xr=nt,this.getContext=function(){return O},this.getContextAttributes=function(){return O.getContextAttributes()},this.forceContextLoss=function(){let A=ge.get("WEBGL_lose_context");A&&A.loseContext()},this.forceContextRestore=function(){let A=ge.get("WEBGL_lose_context");A&&A.restoreContext()},this.getPixelRatio=function(){return dt},this.setPixelRatio=function(A){A!==void 0&&(dt=A,this.setSize(xt,Ct,!1))},this.getSize=function(A){return A.set(xt,Ct)},this.setSize=function(A,F,W=!0){if(nt.isPresenting){Tt("WebGLRenderer: Can't change size while VR device is presenting.");return}xt=A,Ct=F,e.width=Math.floor(A*dt),e.height=Math.floor(F*dt),W===!0&&(e.style.width=A+"px",e.style.height=F+"px"),I!==null&&I.setSize(e.width,e.height),this.setViewport(0,0,A,F)},this.getDrawingBufferSize=function(A){return A.set(xt*dt,Ct*dt).floor()},this.setDrawingBufferSize=function(A,F,W){xt=A,Ct=F,dt=W,e.width=Math.floor(A*W),e.height=Math.floor(F*W),this.setViewport(0,0,A,F)},this.setEffects=function(A){if(v===an){Dt("WebGLRenderer: setEffects() requires outputBufferType set to HalfFloatType or FloatType.");return}if(A){for(let F=0;F<A.length;F++)if(A[F].isOutputPass===!0){Tt("WebGLRenderer: OutputPass is not needed in setEffects(). Tone mapping and color space conversion are applied automatically.");break}}I.setEffects(A||[])},this.getCurrentViewport=function(A){return A.copy(Q)},this.getViewport=function(A){return A.copy(It)},this.setViewport=function(A,F,W,z){A.isVector4?It.set(A.x,A.y,A.z,A.w):It.set(A,F,W,z),ft.viewport(Q.copy(It).multiplyScalar(In()).round())},this.getScissor=function(A){return A.copy(jt)},this.setScissor=function(A,F,W,z){A.isVector4?jt.set(A.x,A.y,A.z,A.w):jt.set(A,F,W,z),ft.scissor(yt.copy(jt).multiplyScalar(In()).round())},this.getScissorTest=function(){return le},this.setScissorTest=function(A){ft.setScissorTest(le=A)},this.setOpaqueSort=function(A){Ot=A},this.setTransparentSort=function(A){Ce=A},this.getClearColor=function(A){return A.copy(D.getClearColor())},this.setClearColor=function(){D.setClearColor(...arguments)},this.getClearAlpha=function(){return D.getClearAlpha()},this.setClearAlpha=function(){D.setClearAlpha(...arguments)},this.clear=function(A=!0,F=!0,W=!0){let z=0;if(A){let V=!1;if(tt!==null){let ut=tt.texture.format;V=m.has(ut)}if(V){let ut=tt.texture.type,vt=p.has(ut),ct=D.getClearColor(),gt=D.getClearAlpha(),bt=ct.r,zt=ct.g,Yt=ct.b;vt?(x[0]=bt,x[1]=zt,x[2]=Yt,x[3]=gt,O.clearBufferuiv(O.COLOR,0,x)):(M[0]=bt,M[1]=zt,M[2]=Yt,M[3]=gt,O.clearBufferiv(O.COLOR,0,M))}else z|=O.COLOR_BUFFER_BIT}F&&(z|=O.DEPTH_BUFFER_BIT,this.state.buffers.depth.setMask(!0)),W&&(z|=O.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),z!==0&&O.clear(z)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.setNodesHandler=function(A){A.setRenderer(this),C=A},this.dispose=function(){e.removeEventListener("webglcontextlost",Rt,!1),e.removeEventListener("webglcontextrestored",Vt,!1),e.removeEventListener("webglcontextcreationerror",pt,!1),D.dispose(),ht.dispose(),Y.dispose(),Bt.dispose(),Lt.dispose(),P.dispose(),et.dispose(),k.dispose(),rt.dispose(),wt.dispose(),$.dispose(),nt.dispose(),nt.removeEventListener("sessionstart",mf),nt.removeEventListener("sessionend",gf),as.stop()};function Rt(A){A.preventDefault(),io("WebGLRenderer: Context Lost."),L=!0}function Vt(){io("WebGLRenderer: Context Restored."),L=!1;let A=ze.autoReset,F=ot.enabled,W=ot.autoUpdate,z=ot.needsUpdate,V=ot.type;Gt(),ze.autoReset=A,ot.enabled=F,ot.autoUpdate=W,ot.needsUpdate=z,ot.type=V}function pt(A){Dt("WebGLRenderer: A WebGL context could not be created. Reason: ",A.statusMessage)}function oe(A){let F=A.target;F.removeEventListener("dispose",oe),We(F)}function We(A){ki(A),Lt.remove(A)}function ki(A){let F=Lt.get(A).programs;F!==void 0&&(F.forEach(function(W){$.releaseProgram(W)}),A.isShaderMaterial&&$.releaseShaderCache(A))}this.renderBufferDirect=function(A,F,W,z,V,ut){F===null&&(F=Cn);let vt=V.isMesh&&V.matrixWorld.determinantAffine()<0,ct=Dm(A,F,W,z,V);ft.setMaterial(z,vt);let gt=W.index,bt=1;if(z.wireframe===!0){if(gt=k.getWireframeAttribute(W),gt===void 0)return;bt=2}let zt=W.drawRange,Yt=W.attributes.position,Mt=zt.start*bt,Kt=(zt.start+zt.count)*bt;ut!==null&&(Mt=Math.max(Mt,ut.start*bt),Kt=Math.min(Kt,(ut.start+ut.count)*bt)),gt!==null?(Mt=Math.max(Mt,0),Kt=Math.min(Kt,gt.count)):Yt!=null&&(Mt=Math.max(Mt,0),Kt=Math.min(Kt,Yt.count));let Ue=Kt-Mt;if(Ue<0||Ue===1/0)return;rt.setup(V,z,ct,W,gt);let pe,he=q;if(gt!==null&&(pe=w.get(gt),he=at,he.setIndex(pe)),V.isMesh)z.wireframe===!0?(ft.setLineWidth(z.wireframeLinewidth*In()),he.setMode(O.LINES)):he.setMode(O.TRIANGLES);else if(V.isLine){let en=z.linewidth;en===void 0&&(en=1),ft.setLineWidth(en*In()),V.isLineSegments?he.setMode(O.LINES):V.isLineLoop?he.setMode(O.LINE_LOOP):he.setMode(O.LINE_STRIP)}else V.isPoints?he.setMode(O.POINTS):V.isSprite&&he.setMode(O.TRIANGLES);if(V.isBatchedMesh)if(ge.get("WEBGL_multi_draw"))he.renderMultiDraw(V._multiDrawStarts,V._multiDrawCounts,V._multiDrawCount);else{let en=V._multiDrawStarts,St=V._multiDrawCounts,un=V._multiDrawCount,te=gt?w.get(gt).bytesPerElement:1,cs=Lt.get(z).currentProgram.getUniforms();for(let nn=0;nn<un;nn++)cs.setValue(O,"_gl_DrawID",nn),he.render(en[nn]/te,St[nn])}else if(V.isInstancedMesh)he.renderInstances(Mt,Ue,V.count);else if(W.isInstancedBufferGeometry){let en=W._maxInstanceCount!==void 0?W._maxInstanceCount:1/0,St=Math.min(W.instanceCount,en);he.renderInstances(Mt,Ue,St)}else he.render(Mt,Ue)};function pf(A,F,W,z){C!==null&&A.isNodeMaterial&&C.setObject(z,A),Be===!0&&K.setState(A,W,!1),A.transparent===!0&&A.side===Pe&&A.forceSinglePass===!1?(A.side=Ne,A.needsUpdate=!0,Wr(A,F,z),A.side=pn,A.needsUpdate=!0,Wr(A,F,z),A.side=Pe):Wr(A,F,z)}this.compile=function(A,F,W=null){W===null&&(W=A),C!==null&&C.renderStart(A,F,W),T=Y.get(W),T.init(F),b.push(T),W.traverseVisible(function(V){V.isLight&&V.layers.test(F.layers)&&(T.pushLight(V),V.castShadow&&T.pushShadow(V))}),A!==W&&A.traverseVisible(function(V){V.isLight&&V.layers.test(F.layers)&&(T.pushLight(V),V.castShadow&&T.pushShadow(V))}),T.setupLights(),C!==null&&C.updateLights(T.state.lightsArray),_n=this.localClippingEnabled,Be=K.init(this.clippingPlanes,_n),Be===!0&&K.setGlobalState(this.clippingPlanes,F),C!==null&&ot.render(T.state.shadowsArray,W,F);let z=new Set;return A.traverse(function(V){if(!(V.isMesh||V.isPoints||V.isLine||V.isSprite))return;let ut=V.material;if(ut)if(Array.isArray(ut))for(let vt=0;vt<ut.length;vt++){let ct=ut[vt];pf(ct,W,F,V),z.add(ct)}else pf(ut,W,F,V),z.add(ut)}),T=b.pop(),C!==null&&C.renderEnd(),z},this.compileAsync=function(A,F,W=null){let z=this.compile(A,F,W);return new Promise(V=>{function ut(){if(z.forEach(function(vt){let gt=Lt.get(vt).currentProgram;(gt===void 0||gt.isReady())&&z.delete(vt)}),z.size===0){V(A);return}setTimeout(ut,10)}ge.get("KHR_parallel_shader_compile")!==null?ut():setTimeout(ut,10)})};let Nl=null;function Lm(A){Nl&&Nl(A)}function mf(){as.stop()}function gf(){as.start()}let as=new Sp;as.setAnimationLoop(Lm),typeof self<"u"&&as.setContext(self),this.setAnimationLoop=function(A){Nl=A,nt.setAnimationLoop(A),A===null?as.stop():as.start()},nt.addEventListener("sessionstart",mf),nt.addEventListener("sessionend",gf),this.render=function(A,F){if(F!==void 0&&F.isCamera!==!0){Dt("WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(L===!0)return;C!==null&&C.renderStart(A,F);let W=nt.enabled===!0&&nt.isPresenting===!0,z=I!==null&&(tt===null||W)&&I.begin(E,tt);if(A.matrixWorldAutoUpdate===!0&&A.updateMatrixWorld(),F.parent===null&&F.matrixWorldAutoUpdate===!0&&F.updateMatrixWorld(),nt.enabled===!0&&nt.isPresenting===!0&&(I===null||I.isCompositing()===!1)&&(nt.cameraAutoUpdate===!0&&nt.updateCamera(F),F=nt.getCamera()),A.isScene===!0&&A.onBeforeRender(E,A,F,tt),T=Y.get(A,b.length),T.init(F),T.state.textureUnits=Bt.getTextureUnits(),b.push(T),Se.multiplyMatrices(F.projectionMatrix,F.matrixWorldInverse),F.isArrayCamera?Ze.setFromArrayCamera(F):qt.setFromProjectionMatrix(Se,Dn,F.reversedDepth),_n=this.localClippingEnabled,Be=K.init(this.clippingPlanes,_n),S=ht.get(A,_.length),S.init(),_.push(S),this.info.render.frame++,nt.enabled===!0&&nt.isPresenting===!0){let vt=E.xr.getDepthSensingMesh();vt!==null&&Dl(vt,F,-1/0,E.sortObjects)}Dl(A,F,0,E.sortObjects),S.finish(),C!==null&&C.updateLights(T.state.lightsArray),E.sortObjects===!0&&S.sort(Ot,Ce),Pn=nt.enabled===!1||nt.isPresenting===!1||nt.hasDepthSensing()===!1,Pn&&D.addToRenderList(S,A),this.info.autoReset===!0&&this.info.reset(),Be===!0&&K.beginShadows();let V=T.state.shadowsArray;if(ot.render(V,A,F),Be===!0&&K.endShadows(),(z&&I.hasRenderPass())===!1){let vt=S.opaque,ct=S.transmissive;if(T.setupLights(),F.isArrayCamera){let gt=F.cameras;if(ct.length>0)for(let bt=0,zt=gt.length;bt<zt;bt++){let Yt=gt[bt];xf(vt,ct,A,Yt)}Pn&&D.render(A);for(let bt=0,zt=gt.length;bt<zt;bt++){let Yt=gt[bt];_f(S,A,Yt,Yt.viewport)}}else ct.length>0&&xf(vt,ct,A,F),Pn&&D.render(A),_f(S,A,F)}tt!==null&&H===0&&(Bt.updateMultisampleRenderTarget(tt),Bt.updateRenderTargetMipmap(tt)),z&&I.end(E),A.isScene===!0&&A.onAfterRender(E,A,F),rt.resetDefaultState(),X=-1,j=null,b.pop(),b.length>0?(T=b[b.length-1],Bt.setTextureUnits(T.state.textureUnits),Be===!0&&K.setGlobalState(E.clippingPlanes,T.state.camera)):T=null,_.pop(),_.length>0?S=_[_.length-1]:S=null,C!==null&&C.renderEnd()};function Dl(A,F,W,z){if(A.visible===!1)return;if(A.layers.test(F.layers)){if(A.isGroup)W=A.renderOrder;else if(A.isLOD)A.autoUpdate===!0&&A.update(F);else if(A.isLight)T.pushLight(A),A.castShadow&&T.pushShadow(A);else if(A.isSprite){let vt=F.isArrayCamera?Ze:qt;if(!A.frustumCulled||A.intersectsFrustum(vt)){z&&He.setFromMatrixPosition(A.matrixWorld).applyMatrix4(Se);let ct=et.update(A),gt=A.material;gt.visible&&S.push(A,ct,gt,W,He.z,null,F)}}else if(A.isMesh||A.isLine||A.isPoints){let vt=F.isArrayCamera?Ze:qt;if(!A.frustumCulled||A.intersectsFrustum(vt)){let ct=et.update(A),gt=A.material;if(z&&(A.boundingSphere!==void 0?(A.boundingSphere===null&&A.computeBoundingSphere(),He.copy(A.boundingSphere.center)):(ct.boundingSphere===null&&ct.computeBoundingSphere(),He.copy(ct.boundingSphere.center)),He.applyMatrix4(A.matrixWorld).applyMatrix4(Se)),Array.isArray(gt)){let bt=ct.groups;for(let zt=0,Yt=bt.length;zt<Yt;zt++){let Mt=bt[zt],Kt=gt[Mt.materialIndex];Kt&&Kt.visible&&S.push(A,ct,Kt,W,He.z,Mt,F)}}else gt.visible&&S.push(A,ct,gt,W,He.z,null,F)}}}let ut=A.children;for(let vt=0,ct=ut.length;vt<ct;vt++)Dl(ut[vt],F,W,z)}function _f(A,F,W,z){let{opaque:V,transmissive:ut,transparent:vt}=A;T.setupLightsView(W),Be===!0&&K.setGlobalState(E.clippingPlanes,W),z&&ft.viewport(Q.copy(z)),V.length>0&&ia(V,F,W),ut.length>0&&ia(ut,F,W),vt.length>0&&ia(vt,F,W),ft.buffers.depth.setTest(!0),ft.buffers.depth.setMask(!0),ft.buffers.color.setMask(!0),ft.setPolygonOffset(!1)}function xf(A,F,W,z){if((W.isScene===!0?W.overrideMaterial:null)!==null)return;if(T.state.transmissionRenderTarget[z.id]===void 0){let Mt=ge.has("EXT_color_buffer_half_float")||ge.has("EXT_color_buffer_float");T.state.transmissionRenderTarget[z.id]=new je(1,1,{generateMipmaps:!0,type:Mt?cn:an,minFilter:Sn,samples:Math.max(4,_e.samples),stencilBuffer:r,resolveDepthBuffer:!1,resolveStencilBuffer:!1,storeMultisampledDepthBuffer:!1,storeMultisampledStencilBuffer:!1,colorSpace:Ht.workingColorSpace})}let ut=T.state.transmissionRenderTarget[z.id],vt=z.viewport||Q;ut.setSize(vt.z*E.transmissionResolutionScale,vt.w*E.transmissionResolutionScale);let ct=E.getRenderTarget(),gt=E.getActiveCubeFace(),bt=E.getActiveMipmapLevel();E.setRenderTarget(ut),E.getClearColor(Z),lt=E.getClearAlpha(),lt<1&&E.setClearColor(16777215,.5),E.clear(),Pn&&D.render(W);let zt=E.toneMapping;E.toneMapping=ri;let Yt=z.viewport;if(z.viewport!==void 0&&(z.viewport=void 0),T.setupLightsView(z),Be===!0&&K.setGlobalState(E.clippingPlanes,z),ia(A,W,z),Bt.updateMultisampleRenderTarget(ut),Bt.updateRenderTargetMipmap(ut),ge.has("WEBGL_multisampled_render_to_texture")===!1){let Mt=!1;for(let Kt=0,Ue=F.length;Kt<Ue;Kt++){let pe=F[Kt],{object:he,geometry:en,material:St,group:un}=pe;if(St.side===Pe&&he.layers.test(z.layers)){let te=St.side;St.side=Ne,St.needsUpdate=!0,yf(he,W,z,en,St,un),St.side=te,St.needsUpdate=!0,Mt=!0}}Mt===!0&&(Bt.updateMultisampleRenderTarget(ut),Bt.updateRenderTargetMipmap(ut))}E.setRenderTarget(ct,gt,bt),E.setClearColor(Z,lt),Yt!==void 0&&(z.viewport=Yt),E.toneMapping=zt}function ia(A,F,W){let z=F.isScene===!0?F.overrideMaterial:null;for(let V=0,ut=A.length;V<ut;V++){let vt=A[V],{object:ct,geometry:gt,group:bt}=vt,zt=vt.material;zt.allowOverride===!0&&z!==null&&(zt=z),ct.layers.test(W.layers)&&yf(ct,F,W,gt,zt,bt)}}function yf(A,F,W,z,V,ut){C!==null&&V.isNodeMaterial&&C.setObject(A,V),A.onBeforeRender(E,F,W,z,V,ut),A.modelViewMatrix.multiplyMatrices(W.matrixWorldInverse,A.matrixWorld),A.normalMatrix.getNormalMatrix(A.modelViewMatrix),V.onBeforeRender(E,F,W,z,A,ut),V.transparent===!0&&V.side===Pe&&V.forceSinglePass===!1?(V.side=Ne,V.needsUpdate=!0,E.renderBufferDirect(W,F,z,V,A,ut),V.side=pn,V.needsUpdate=!0,E.renderBufferDirect(W,F,z,V,A,ut),V.side=Pe):E.renderBufferDirect(W,F,z,V,A,ut),A.onAfterRender(E,F,W,z,V,ut)}function vf(A){let F=0;for(let W of A)W.texture!==null&&F++;return F}function Wr(A,F,W){F.isScene!==!0&&(F=Cn);let z=Lt.get(A),V=T.state.lights,ut=T.state.shadowsArray,vt=V.state.version,ct=$.getParameters(A,V.state,ut,F,W,T.state.lightProbeGridArray),gt=$.getProgramCacheKey(ct),bt=z.programs;z.environment=A.isMeshStandardMaterial||A.isMeshLambertMaterial||A.isMeshPhongMaterial?F.environment:null,z.fog=F.fog;let zt=A.isMeshStandardMaterial||A.isMeshLambertMaterial&&!A.envMap||A.isMeshPhongMaterial&&!A.envMap;z.envMap=P.get(A.envMap||z.environment,zt),z.envMapRotation=z.environment!==null&&A.envMap===null?F.environmentRotation:A.envMapRotation,bt===void 0&&(A.addEventListener("dispose",oe),bt=new Map,z.programs=bt,z.programVariants=new Map);let Yt=bt.get(gt);if(Yt!==void 0){if(z.currentProgram===Yt&&z.lightsStateVersion===vt)return Sf(A,ct),Yt}else ct.uniforms=$.getUniforms(A),C!==null&&A.isNodeMaterial&&C.build(A,W,ct),A.onBeforeCompile(ct,E),Yt=$.acquireProgram(ct,gt),bt.set(gt,Yt),z.uniforms=ct.uniforms;let Mt=z.uniforms;return(!A.isShaderMaterial&&!A.isRawShaderMaterial||A.clipping===!0)&&(Mt.clippingPlanes=K.uniform),Sf(A,ct),z.needsLights=Fm(A),z.lightsStateVersion=vt,z.needsLights&&(Mt.ambientLightColor.value=V.state.ambient,Mt.lightProbe.value=V.state.probe,Mt.sunLights.value=V.state.sun,Mt.sunLightShadows.value=V.state.sunShadow,Mt.directionalLights.value=V.state.directional,Mt.directionalLightShadows.value=V.state.directionalShadow,Mt.spotLights.value=V.state.spot,Mt.spotLightShadows.value=V.state.spotShadow,Mt.rectAreaLights.value=V.state.rectArea,Mt.ltc_1.value=V.state.rectAreaLTC1,Mt.ltc_2.value=V.state.rectAreaLTC2,Mt.pointLights.value=V.state.point,Mt.pointLightShadows.value=V.state.pointShadow,Mt.hemisphereLights.value=V.state.hemi,Mt.sunShadowMatrix.value=V.state.sunShadowMatrix,Mt.sunShadowCascade.value=V.state.sunShadowCascade,Mt.directionalShadowMatrix.value=V.state.directionalShadowMatrix,Mt.spotLightMatrix.value=V.state.spotLightMatrix,Mt.spotLightMap.value=V.state.spotLightMap,Mt.pointShadowMatrix.value=V.state.pointShadowMatrix),z.numLightProbeGrids=vf(T.state.lightProbeGridArray),z.currentProgram=Yt,z.uniformsList=null,Yt}function Nm(A,F,W,z,V){let ut=Lt.get(A),vt=ut.currentProgram.id+","+z+","+V,ct=ut.programVariants.get(vt);return ct===void 0?(ct=Wr(A,F,W),ut.programVariants.set(vt,ct)):(ut.currentProgram=ct,ut.uniformsList=null,ut.outputColorSpace=z,ut.toneMapping=V),ct}function Mf(A){if(A.uniformsList===null){let F=A.currentProgram.getUniforms();A.uniformsList=Ar.seqWithValue(F.seq,A.uniforms)}return A.uniformsList}function Sf(A,F){let W=Lt.get(A);W.outputColorSpace=F.outputColorSpace,W.batching=F.batching,W.batchingColor=F.batchingColor,W.instancing=F.instancing,W.instancingColor=F.instancingColor,W.instancingMorph=F.instancingMorph,W.skinning=F.skinning,W.morphTargets=F.morphTargets,W.morphNormals=F.morphNormals,W.morphColors=F.morphColors,W.morphTargetsCount=F.morphTargetsCount,W.numClippingPlanes=F.numClippingPlanes,W.numIntersection=F.numClipIntersection,W.vertexAlphas=F.vertexAlphas,W.vertexTangents=F.vertexTangents,W.toneMapping=F.toneMapping}function Dm(A,F,W,z,V){F.isScene!==!0&&(F=Cn),Bt.resetTextureUnits();let ut=F.fog,vt=z.isMeshStandardMaterial||z.isMeshLambertMaterial||z.isMeshPhongMaterial?F.environment:null,ct=tt===null?E.outputColorSpace:tt.isXRRenderTarget===!0?tt.texture.colorSpace:Ht.workingColorSpace,gt=z.isMeshStandardMaterial||z.isMeshLambertMaterial&&!z.envMap||z.isMeshPhongMaterial&&!z.envMap,bt=P.get(z.envMap||vt,gt),zt=z.vertexColors===!0&&!!W.attributes.color&&W.attributes.color.itemSize===4,Yt=!!W.attributes.tangent&&(!!z.normalMap||z.anisotropy>0),Mt=!!W.morphAttributes.position,Kt=!!W.morphAttributes.normal,Ue=!!W.morphAttributes.color,pe=ri;z.toneMapped&&(tt===null||tt.isXRRenderTarget===!0)&&(pe=E.toneMapping);let he=W.morphAttributes.position||W.morphAttributes.normal||W.morphAttributes.color,en=he!==void 0?he.length:0,St=Lt.get(z),un=T.state.lights;if(Be===!0&&(_n===!0||A!==j)){let be=A===j&&z.id===X;K.setState(z,A,be)}let te=!1,cs=!1;z.version===St.__version?St.needsLights&&St.lightsStateVersion!==un.state.version||V.isBatchedMesh&&St.batching===!1||!V.isBatchedMesh&&St.batching===!0||V.isBatchedMesh&&St.batchingColor===!0&&V._colorsTexture===null||V.isBatchedMesh&&St.batchingColor===!1&&V._colorsTexture!==null||V.isInstancedMesh&&St.instancing===!1||!V.isInstancedMesh&&St.instancing===!0||V.isSkinnedMesh&&St.skinning===!1||!V.isSkinnedMesh&&St.skinning===!0||V.isInstancedMesh&&St.instancingColor===!0&&V.instanceColor===null||V.isInstancedMesh&&St.instancingColor===!1&&V.instanceColor!==null||V.isInstancedMesh&&St.instancingMorph===!0&&V.morphTexture===null||V.isInstancedMesh&&St.instancingMorph===!1&&V.morphTexture!==null||St.envMap!==bt||z.fog===!0&&St.fog!==ut||St.numClippingPlanes!==void 0&&(St.numClippingPlanes!==K.numPlanes||St.numIntersection!==K.numIntersection)||St.vertexAlphas!==zt||St.vertexTangents!==Yt||St.morphTargets!==Mt||St.morphNormals!==Kt||St.morphColors!==Ue||St.morphTargetsCount!==en||St.numLightProbeGrids!==vf(T.state.lightProbeGridArray)?te=!0:(St.outputColorSpace!==ct||St.toneMapping!==pe)&&(cs=!0):(te=!0,St.__version=z.version);let nn=St.currentProgram;(te===!0||cs===!0)&&(nn=cs===!0?Nm(z,F,V,ct,pe):Wr(z,F,V),C&&z.isNodeMaterial&&C.onUpdateProgram(z,nn,St));let sa=!1,Vi=!1,ls=!1,Qt=nn.getUniforms(),Je=St.uniforms;if(ft.useProgram(nn.program)&&(sa=!0,Vi=!0,ls=!0),z.id!==X&&(X=z.id,Vi=!0),sa||j!==A){ft.buffers.depth.getReversed()&&A.reversedDepth!==!0&&(A._reversedDepth=!0,A.updateProjectionMatrix()),Qt.setValue(O,"projectionMatrix",A.projectionMatrix),Qt.setValue(O,"viewMatrix",A.matrixWorldInverse);let Xe=Qt.map.cameraPosition;Xe!==void 0&&Xe.setValue(O,Jn.setFromMatrixPosition(A.matrixWorld)),_e.logarithmicDepthBuffer&&Qt.setValue(O,"logDepthBufFC",2/(Math.log(A.far+1)/Math.LN2)),(z.isMeshPhongMaterial||z.isMeshToonMaterial||z.isMeshLambertMaterial||z.isMeshBasicMaterial||z.isMeshStandardMaterial||z.isShaderMaterial)&&Qt.setValue(O,"isOrthographic",A.isOrthographicCamera===!0),j!==A&&(j=A,Vi=!0,ls=!0)}if(St.needsLights&&(un.state.sunShadowMap.length>0&&Qt.setValue(O,"sunShadowMap",un.state.sunShadowMap,Bt),un.state.directionalShadowMap.length>0&&Qt.setValue(O,"directionalShadowMap",un.state.directionalShadowMap,Bt),un.state.spotShadowMap.length>0&&Qt.setValue(O,"spotShadowMap",un.state.spotShadowMap,Bt),un.state.pointShadowMap.length>0&&Qt.setValue(O,"pointShadowMap",un.state.pointShadowMap,Bt)),V.isSkinnedMesh){Qt.setOptional(O,V,"bindMatrix"),Qt.setOptional(O,V,"bindMatrixInverse");let be=V.skeleton;be&&(be.boneTexture===null&&be.computeBoneTexture(),Qt.setValue(O,"boneTexture",be.boneTexture,Bt))}V.isBatchedMesh&&(Qt.setOptional(O,V,"batchingTexture"),Qt.setValue(O,"batchingTexture",V._matricesTexture,Bt),Qt.setOptional(O,V,"batchingIdTexture"),Qt.setValue(O,"batchingIdTexture",V._indirectTexture,Bt),Qt.setOptional(O,V,"batchingColorTexture"),V._colorsTexture!==null&&Qt.setValue(O,"batchingColorTexture",V._colorsTexture,Bt));let zn=W.morphAttributes;if((zn.position!==void 0||zn.normal!==void 0||zn.color!==void 0)&&J.update(V,W,nn),(Vi||St.receiveShadow!==V.receiveShadow)&&(St.receiveShadow=V.receiveShadow,Qt.setValue(O,"receiveShadow",V.receiveShadow)),(z.isMeshStandardMaterial||z.isMeshLambertMaterial||z.isMeshPhongMaterial)&&z.envMap===null&&F.environment!==null&&(Je.envMapIntensity.value=F.environmentIntensity),Je.dfgLUT!==void 0&&(Je.dfgLUT.value=Cv()),Vi){if(Qt.setValue(O,"toneMappingExposure",E.toneMappingExposure),St.needsLights&&Um(Je,ls),ut&&z.fog===!0&&st.refreshFogUniforms(Je,ut),st.refreshMaterialUniforms(Je,z,dt,Ct,T.state.transmissionRenderTarget[A.id]),St.needsLights&&St.numLightProbeGrids>0){let be=y,Xe=0;for(let pi of T.state.lightProbeGridArray)pi.texture!==null&&(be.textures[Xe]=pi.texture,be.min[Xe]=pi.boundingBox.min,be.max[Xe]=pi.boundingBox.max,be.resolution[Xe]=pi.resolution,Xe++);for(let pi in be)be[pi].length=Xe;Je.probesSH.value=be.textures,Je.probesMin.value=be.min,Je.probesMax.value=be.max,Je.probesResolution.value=be.resolution}Ar.upload(O,Mf(St),Je,Bt)}if(z.isShaderMaterial&&z.uniformsNeedUpdate===!0&&(Ar.upload(O,Mf(St),Je,Bt),z.uniformsNeedUpdate=!1),z.isSpriteMaterial&&Qt.setValue(O,"center",V.center),Qt.setValue(O,"modelViewMatrix",V.modelViewMatrix),Qt.setValue(O,"normalMatrix",V.normalMatrix),Qt.setValue(O,"modelMatrix",V.matrixWorld),z.uniformsGroups!==void 0){let be=z.uniformsGroups;for(let Xe=0,pi=be.length;Xe<pi;Xe++){let Tf=be[Xe];wt.update(Tf,nn),wt.bind(Tf,nn)}}return nn}function Um(A,F){A.ambientLightColor.needsUpdate=F,A.lightProbe.needsUpdate=F,A.sunLights.needsUpdate=F,A.sunLightShadows.needsUpdate=F,A.directionalLights.needsUpdate=F,A.directionalLightShadows.needsUpdate=F,A.pointLights.needsUpdate=F,A.pointLightShadows.needsUpdate=F,A.spotLights.needsUpdate=F,A.spotLightShadows.needsUpdate=F,A.rectAreaLights.needsUpdate=F,A.hemisphereLights.needsUpdate=F}function Fm(A){return A.isMeshLambertMaterial||A.isMeshToonMaterial||A.isMeshPhongMaterial||A.isMeshStandardMaterial||A.isShadowMaterial||A.isShaderMaterial&&A.lights===!0}this.getActiveCubeFace=function(){return G},this.getActiveMipmapLevel=function(){return H},this.getRenderTarget=function(){return tt},this.setRenderTargetTextures=function(A,F,W){let z=Lt.get(A);z.__autoAllocateDepthBuffer=A.resolveDepthBuffer===!1,z.__autoAllocateDepthBuffer===!1&&(z.__useRenderToTexture=!1),Lt.get(A.texture).__webglTexture=F,Lt.get(A.depthTexture).__webglTexture=z.__autoAllocateDepthBuffer?void 0:W,z.__hasExternalTextures=!0},this.setRenderTargetFramebuffer=function(A,F){let W=Lt.get(A);W.__webglFramebuffer=F,W.__useDefaultFramebuffer=F===void 0},this.setRenderTarget=function(A,F=0,W=0){tt=A,G=F,H=W;let z=null,V=!1,ut=!1;if(A){let ct=Lt.get(A);if(ct.__useDefaultFramebuffer!==void 0){ft.bindFramebuffer(O.FRAMEBUFFER,ct.__webglFramebuffer),Q.copy(A.viewport),yt.copy(A.scissor),Ut=A.scissorTest,ft.viewport(Q),ft.scissor(yt),ft.setScissorTest(Ut),X=-1;return}else if(ct.__webglFramebuffer===void 0)Bt.setupRenderTarget(A);else if(ct.__hasExternalTextures)Bt.rebindTextures(A,Lt.get(A.texture).__webglTexture,Lt.get(A.depthTexture).__webglTexture);else if(A.depthBuffer){let zt=A.depthTexture;if(ct.__boundDepthTexture!==zt){if(zt!==null&&Lt.has(zt)&&(A.width!==zt.image.width||A.height!==zt.image.height))throw new Error("THREE.WebGLRenderer: Attached DepthTexture is initialized to the incorrect size.");Bt.setupDepthRenderbuffer(A)}}let gt=A.texture;(gt.isData3DTexture||gt.isDataArrayTexture||gt.isCompressedArrayTexture)&&(ut=!0);let bt=Lt.get(A).__webglFramebuffer;A.isWebGLCubeRenderTarget?(Array.isArray(bt[F])?z=bt[F][W]:z=bt[F],V=!0):A.samples>0&&Bt.useMultisampledRTT(A)===!1?z=Lt.get(A).__webglMultisampledFramebuffer:Array.isArray(bt)?z=bt[W]:z=bt,Q.copy(A.viewport),yt.copy(A.scissor),Ut=A.scissorTest}else Q.copy(It).multiplyScalar(dt).floor(),yt.copy(jt).multiplyScalar(dt).floor(),Ut=le;if(W!==0&&(z=U),ft.bindFramebuffer(O.FRAMEBUFFER,z)&&ft.drawBuffers(A,z),ft.viewport(Q),ft.scissor(yt),ft.setScissorTest(Ut),V){let ct=Lt.get(A.texture);O.framebufferTexture2D(O.FRAMEBUFFER,O.COLOR_ATTACHMENT0,O.TEXTURE_CUBE_MAP_POSITIVE_X+F,ct.__webglTexture,W)}else if(ut){let ct=F;for(let gt=0;gt<A.textures.length;gt++){let bt=Lt.get(A.textures[gt]);O.framebufferTextureLayer(O.FRAMEBUFFER,O.COLOR_ATTACHMENT0+gt,bt.__webglTexture,W,ct)}}else if(A!==null&&W!==0){let ct=Lt.get(A.texture);O.framebufferTexture2D(O.FRAMEBUFFER,O.COLOR_ATTACHMENT0,O.TEXTURE_2D,ct.__webglTexture,W)}X=-1};function bf(A){let F=Lt.get(A);return(F.__readFormat!==A.format||F.__readType!==A.type)&&(F.__readFormat=A.format,F.__readType=A.type,F.__formatReadable=_e.textureFormatReadable(A.format),F.__typeReadable=_e.textureTypeReadable(A.type)),F}this.readRenderTargetPixels=function(A,F,W,z,V,ut,vt,ct=0){if(!(A&&A.isWebGLRenderTarget)){Dt("WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let gt=Lt.get(A).__webglFramebuffer;if(A.isWebGLCubeRenderTarget&&vt!==void 0&&(gt=gt[vt],Array.isArray(gt)&&(gt=gt[0])),gt){ft.bindFramebuffer(O.FRAMEBUFFER,gt);try{let bt=A.textures[ct],zt=bt.format,Yt=bt.type;A.textures.length>1&&O.readBuffer(O.COLOR_ATTACHMENT0+ct);let Mt=bf(bt);if(Mt.__formatReadable===!1){Dt("WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}if(Mt.__typeReadable===!1){Dt("WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}F>=0&&F<=A.width-z&&W>=0&&W<=A.height-V&&O.readPixels(F,W,z,V,it.convert(zt),it.convert(Yt),ut)}finally{let bt=tt!==null?Lt.get(tt).__webglFramebuffer:null;ft.bindFramebuffer(O.FRAMEBUFFER,bt)}}},this.readRenderTargetPixelsAsync=async function(A,F,W,z,V,ut,vt,ct=0){if(!(A&&A.isWebGLRenderTarget))throw new Error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");let gt=Lt.get(A).__webglFramebuffer;if(A.isWebGLCubeRenderTarget&&vt!==void 0&&(gt=gt[vt],Array.isArray(gt)&&(gt=gt[0])),gt)if(F>=0&&F<=A.width-z&&W>=0&&W<=A.height-V){ft.bindFramebuffer(O.FRAMEBUFFER,gt);let bt=A.textures[ct],zt=bt.format,Yt=bt.type;A.textures.length>1&&O.readBuffer(O.COLOR_ATTACHMENT0+ct);let Mt=bf(bt);if(Mt.__formatReadable===!1)throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in RGBA or implementation defined format.");if(Mt.__typeReadable===!1)throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: renderTarget is not in UnsignedByteType or implementation defined type.");let Kt=O.createBuffer();O.bindBuffer(O.PIXEL_PACK_BUFFER,Kt),O.bufferData(O.PIXEL_PACK_BUFFER,ut.byteLength,O.STREAM_READ),O.readPixels(F,W,z,V,it.convert(zt),it.convert(Yt),0),O.bindBuffer(O.PIXEL_PACK_BUFFER,null);let Ue=tt!==null?Lt.get(tt).__webglFramebuffer:null;ft.bindFramebuffer(O.FRAMEBUFFER,Ue);let pe=O.fenceSync(O.SYNC_GPU_COMMANDS_COMPLETE,0);return O.flush(),await Zd(O,pe,4),O.bindBuffer(O.PIXEL_PACK_BUFFER,Kt),O.getBufferSubData(O.PIXEL_PACK_BUFFER,0,ut),O.bindBuffer(O.PIXEL_PACK_BUFFER,null),O.deleteBuffer(Kt),O.deleteSync(pe),ut}else throw new Error("THREE.WebGLRenderer.readRenderTargetPixelsAsync: requested read bounds are out of range.")},this.copyFramebufferToTexture=function(A,F=null,W=0){let z=Math.pow(2,-W),V=Math.floor(A.image.width*z),ut=Math.floor(A.image.height*z),vt=F!==null?F.x:0,ct=F!==null?F.y:0;Bt.setTexture2D(A,0),O.copyTexSubImage2D(O.TEXTURE_2D,W,0,0,vt,ct,V,ut),ft.unbindTexture()},this.copyTextureToTexture=function(A,F,W=null,z=null,V=0,ut=0){let vt,ct,gt,bt,zt,Yt,Mt,Kt,Ue,pe=A.isCompressedTexture?A.mipmaps[ut]:A.image;if(W!==null)vt=W.max.x-W.min.x,ct=W.max.y-W.min.y,gt=W.isBox3?W.max.z-W.min.z:1,bt=W.min.x,zt=W.min.y,Yt=W.isBox3?W.min.z:0;else{let Qt=Math.pow(2,-V);vt=Math.floor(pe.width*Qt),ct=Math.floor(pe.height*Qt),A.isDataArrayTexture?gt=pe.depth:A.isData3DTexture?gt=Math.floor(pe.depth*Qt):gt=1,bt=0,zt=0,Yt=0}z!==null?(Mt=z.x,Kt=z.y,Ue=z.z):(Mt=0,Kt=0,Ue=0);let he=it.convert(F.format),en=it.convert(F.type),St;F.isData3DTexture?(Bt.setTexture3D(F,0),St=O.TEXTURE_3D):F.isDataArrayTexture||F.isCompressedArrayTexture?(Bt.setTexture2DArray(F,0),St=O.TEXTURE_2D_ARRAY):(Bt.setTexture2D(F,0),St=O.TEXTURE_2D),ft.activeTexture(O.TEXTURE0),ft.pixelStorei(O.UNPACK_FLIP_Y_WEBGL,F.flipY),ft.pixelStorei(O.UNPACK_PREMULTIPLY_ALPHA_WEBGL,F.premultiplyAlpha),ft.pixelStorei(O.UNPACK_ALIGNMENT,F.unpackAlignment);let un=ft.getParameter(O.UNPACK_ROW_LENGTH),te=ft.getParameter(O.UNPACK_IMAGE_HEIGHT),cs=ft.getParameter(O.UNPACK_SKIP_PIXELS),nn=ft.getParameter(O.UNPACK_SKIP_ROWS),sa=ft.getParameter(O.UNPACK_SKIP_IMAGES);ft.pixelStorei(O.UNPACK_ROW_LENGTH,pe.width),ft.pixelStorei(O.UNPACK_IMAGE_HEIGHT,pe.height),ft.pixelStorei(O.UNPACK_SKIP_PIXELS,bt),ft.pixelStorei(O.UNPACK_SKIP_ROWS,zt),ft.pixelStorei(O.UNPACK_SKIP_IMAGES,Yt);let Vi=A.isDataArrayTexture||A.isData3DTexture,ls=F.isDataArrayTexture||F.isData3DTexture;if(A.isDepthTexture){let Qt=Lt.get(A),Je=Lt.get(F),zn=Lt.get(Qt.__renderTarget),be=Lt.get(Je.__renderTarget);ft.bindFramebuffer(O.READ_FRAMEBUFFER,zn.__webglFramebuffer),ft.bindFramebuffer(O.DRAW_FRAMEBUFFER,be.__webglFramebuffer);for(let Xe=0;Xe<gt;Xe++)Vi&&(O.framebufferTextureLayer(O.READ_FRAMEBUFFER,O.COLOR_ATTACHMENT0,Lt.get(A).__webglTexture,V,Yt+Xe),O.framebufferTextureLayer(O.DRAW_FRAMEBUFFER,O.COLOR_ATTACHMENT0,Lt.get(F).__webglTexture,ut,Ue+Xe)),O.blitFramebuffer(bt,zt,bt+vt,zt+ct,Mt,Kt,Mt+vt,Kt+ct,O.DEPTH_BUFFER_BIT,O.NEAREST);ft.bindFramebuffer(O.READ_FRAMEBUFFER,null),ft.bindFramebuffer(O.DRAW_FRAMEBUFFER,null)}else if(V!==0||A.isRenderTargetTexture||Lt.has(A)){let Qt=Lt.get(A),Je=Lt.get(F);ft.bindFramebuffer(O.READ_FRAMEBUFFER,N),ft.bindFramebuffer(O.DRAW_FRAMEBUFFER,B);for(let zn=0;zn<gt;zn++)Vi?O.framebufferTextureLayer(O.READ_FRAMEBUFFER,O.COLOR_ATTACHMENT0,Qt.__webglTexture,V,Yt+zn):O.framebufferTexture2D(O.READ_FRAMEBUFFER,O.COLOR_ATTACHMENT0,O.TEXTURE_2D,Qt.__webglTexture,V),ls?O.framebufferTextureLayer(O.DRAW_FRAMEBUFFER,O.COLOR_ATTACHMENT0,Je.__webglTexture,ut,Ue+zn):O.framebufferTexture2D(O.DRAW_FRAMEBUFFER,O.COLOR_ATTACHMENT0,O.TEXTURE_2D,Je.__webglTexture,ut),V!==0?O.blitFramebuffer(bt,zt,bt+vt,zt+ct,Mt,Kt,Mt+vt,Kt+ct,O.COLOR_BUFFER_BIT,O.NEAREST):ls?O.copyTexSubImage3D(St,ut,Mt,Kt,Ue+zn,bt,zt,vt,ct):O.copyTexSubImage2D(St,ut,Mt,Kt,bt,zt,vt,ct);ft.bindFramebuffer(O.READ_FRAMEBUFFER,null),ft.bindFramebuffer(O.DRAW_FRAMEBUFFER,null)}else ls?A.isDataTexture||A.isData3DTexture?O.texSubImage3D(St,ut,Mt,Kt,Ue,vt,ct,gt,he,en,pe.data):F.isCompressedArrayTexture?O.compressedTexSubImage3D(St,ut,Mt,Kt,Ue,vt,ct,gt,he,pe.data):O.texSubImage3D(St,ut,Mt,Kt,Ue,vt,ct,gt,he,en,pe):A.isDataTexture?O.texSubImage2D(O.TEXTURE_2D,ut,Mt,Kt,vt,ct,he,en,pe.data):A.isCompressedTexture?O.compressedTexSubImage2D(O.TEXTURE_2D,ut,Mt,Kt,pe.width,pe.height,he,pe.data):O.texSubImage2D(O.TEXTURE_2D,ut,Mt,Kt,vt,ct,he,en,pe);ft.pixelStorei(O.UNPACK_ROW_LENGTH,un),ft.pixelStorei(O.UNPACK_IMAGE_HEIGHT,te),ft.pixelStorei(O.UNPACK_SKIP_PIXELS,cs),ft.pixelStorei(O.UNPACK_SKIP_ROWS,nn),ft.pixelStorei(O.UNPACK_SKIP_IMAGES,sa),ut===0&&F.generateMipmaps===!0&&F.mipmapsAutoUpdate===!0&&O.generateMipmap(St),ft.unbindTexture()},this.initRenderTarget=function(A){Lt.get(A).__webglFramebuffer===void 0&&Bt.setupRenderTarget(A)},this.initTexture=function(A){A.isCubeTexture?Bt.setTextureCube(A,0):A.isData3DTexture?Bt.setTexture3D(A,0):A.isDataArrayTexture||A.isCompressedArrayTexture?Bt.setTexture2DArray(A,0):Bt.setTexture2D(A,0),ft.unbindTexture()},this.resetState=function(){G=0,H=0,tt=null,ft.reset(),rt.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return Dn}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(t){this._outputColorSpace=t;let e=this.getContext();e.drawingBufferColorSpace=Ht._getDrawingBufferColorSpace(t),e.unpackColorSpace=Ht._getUnpackColorSpace()}};function lu(s,t){if(t===Dh)return console.warn("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Geometry already defined as triangles."),s;if(t===wr||t===zo){let e=s.getIndex();if(e===null){let r=[],o=s.getAttribute("position");if(o!==void 0){for(let a=0;a<o.count;a++)r.push(a);s.setIndex(r),e=s.getIndex()}else return console.error("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Undefined position attribute. Processing not possible."),s}let n=e.count-2,i=[];if(t===wr)for(let r=1;r<=n;r++)i.push(e.getX(0)),i.push(e.getX(r)),i.push(e.getX(r+1));else for(let r=0;r<n;r++)r%2===0?(i.push(e.getX(r)),i.push(e.getX(r+1)),i.push(e.getX(r+2))):(i.push(e.getX(r+2)),i.push(e.getX(r+1)),i.push(e.getX(r)));return i.length/3!==n&&console.error("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Unable to generate correct amount of triangles."),s.setIndex(i),s.clearGroups(),s}else return console.error("THREE.BufferGeometryUtils.toTrianglesDrawMode(): Unknown draw mode:",t),s}function Np(s){let t=new Map,e=new Map,n=s.clone();return Dp(s,n,function(i,r){t.set(r,i),e.set(i,r)}),n.traverse(function(i){if(!i.isSkinnedMesh)return;let r=i,o=t.get(i),a=o.skeleton.bones;r.skeleton=o.skeleton.clone(),r.bindMatrix.copy(o.bindMatrix),r.skeleton.bones=a.map(function(c){return e.get(c)}),r.bind(r.skeleton,r.bindMatrix)}),n}function Dp(s,t,e){e(s,t);for(let n=0;n<s.children.length;n++)Dp(s.children[n],t.children[n],e)}var Jc=class extends ii{constructor(t){super(t),this.dracoLoader=null,this.ktx2Loader=null,this.meshoptDecoder=null,this.pluginCallbacks=[],this.register(function(e){return new gu(e)}),this.register(function(e){return new _u(e)}),this.register(function(e){return new xu(e)}),this.register(function(e){return new Eu(e)}),this.register(function(e){return new Ru(e)}),this.register(function(e){return new Cu(e)}),this.register(function(e){return new vu(e)}),this.register(function(e){return new Mu(e)}),this.register(function(e){return new Su(e)}),this.register(function(e){return new bu(e)}),this.register(function(e){return new mu(e)}),this.register(function(e){return new Tu(e)}),this.register(function(e){return new yu(e)}),this.register(function(e){return new Au(e)}),this.register(function(e){return new wu(e)}),this.register(function(e){return new du(e)}),this.register(function(e){return new $c(e,Wt.EXT_MESHOPT_COMPRESSION)}),this.register(function(e){return new $c(e,Wt.KHR_MESHOPT_COMPRESSION)}),this.register(function(e){return new Pu(e)})}load(t,e,n,i){let r=this,o;if(this.resourcePath!=="")o=this.resourcePath;else if(this.path!==""){let l=Ni.extractUrlBase(t);o=Ni.resolveURL(l,this.path)}else o=Ni.extractUrlBase(t);this.manager.itemStart(t);let a=function(l){i?i(l):console.error(l),r.manager.itemError(t),r.manager.itemEnd(t)},c=new gr(this.manager);c.setPriority(this.priority),c.setCache(this.cache),c.setPath(this.path),c.setResponseType("arraybuffer"),c.setRequestHeader(this.requestHeader),c.setWithCredentials(this.withCredentials),c.load(t,function(l){try{r.parse(l,o,function(h){e(h),r.manager.itemEnd(t)},a)}catch(h){a(h)}},n,a)}setDRACOLoader(t){return this.dracoLoader=t,this}setKTX2Loader(t){return this.ktx2Loader=t,this}setMeshoptDecoder(t){return this.meshoptDecoder=t,this}register(t){return this.pluginCallbacks.indexOf(t)===-1&&this.pluginCallbacks.push(t),this}unregister(t){return this.pluginCallbacks.indexOf(t)!==-1&&this.pluginCallbacks.splice(this.pluginCallbacks.indexOf(t),1),this}parse(t,e,n,i){let r,o={},a={},c=new TextDecoder;if(typeof t=="string")r=JSON.parse(t);else if(t instanceof ArrayBuffer)if(c.decode(new Uint8Array(t,0,4))===zp){try{o[Wt.KHR_BINARY_GLTF]=new Iu(t)}catch(f){i&&i(f);return}r=JSON.parse(o[Wt.KHR_BINARY_GLTF].content)}else r=JSON.parse(c.decode(t));else r=t;if(r.asset===void 0||r.asset.version[0]<2){i&&i(new Error("THREE.GLTFLoader: Unsupported asset. glTF versions >=2.0 are supported."));return}let l=new Bu(r,{path:e||this.resourcePath||"",crossOrigin:this.crossOrigin,priority:this.priority,cache:this.cache,withCredentials:this.withCredentials,requestHeader:this.requestHeader,manager:this.manager,ktx2Loader:this.ktx2Loader,meshoptDecoder:this.meshoptDecoder});l.fileLoader.setRequestHeader(this.requestHeader);for(let h=0;h<this.pluginCallbacks.length;h++){let f=this.pluginCallbacks[h](l);f.name||console.error("THREE.GLTFLoader: Invalid plugin found: missing name"),a[f.name]=f,o[f.name]=!0}if(r.extensionsUsed)for(let h=0;h<r.extensionsUsed.length;++h){let f=r.extensionsUsed[h],u=r.extensionsRequired||[];switch(f){case Wt.KHR_MATERIALS_UNLIT:o[f]=new pu;break;case Wt.KHR_DRACO_MESH_COMPRESSION:o[f]=new Lu(r,this.dracoLoader);break;case Wt.KHR_TEXTURE_TRANSFORM:o[f]=new Nu;break;case Wt.KHR_MESH_QUANTIZATION:o[f]=new Du;break;default:u.indexOf(f)>=0&&a[f]===void 0&&console.warn('THREE.GLTFLoader: Unknown extension "'+f+'".')}}l.setExtensions(o),l.setPlugins(a),l.parse(n,i)}parseAsync(t,e){let n=this;return new Promise(function(i,r){n.parse(t,e,i,r)})}};function Pv(){let s={};return{get:function(t){return s[t]},add:function(t,e){s[t]=e},remove:function(t){delete s[t]},removeAll:function(){s={}}}}function Re(s,t,e){let n=s.json.materials[t];return n.extensions&&n.extensions[e]?n.extensions[e]:null}var Wt={KHR_BINARY_GLTF:"KHR_binary_glTF",KHR_DRACO_MESH_COMPRESSION:"KHR_draco_mesh_compression",KHR_LIGHTS_PUNCTUAL:"KHR_lights_punctual",KHR_MATERIALS_CLEARCOAT:"KHR_materials_clearcoat",KHR_MATERIALS_DIFFUSE_ROUGHNESS:"KHR_materials_diffuse_roughness",KHR_MATERIALS_DISPERSION:"KHR_materials_dispersion",KHR_MATERIALS_IOR:"KHR_materials_ior",KHR_MATERIALS_SHEEN:"KHR_materials_sheen",KHR_MATERIALS_SPECULAR:"KHR_materials_specular",KHR_MATERIALS_TRANSMISSION:"KHR_materials_transmission",KHR_MATERIALS_IRIDESCENCE:"KHR_materials_iridescence",KHR_MATERIALS_ANISOTROPY:"KHR_materials_anisotropy",KHR_MATERIALS_UNLIT:"KHR_materials_unlit",KHR_MATERIALS_VOLUME:"KHR_materials_volume",KHR_TEXTURE_BASISU:"KHR_texture_basisu",KHR_TEXTURE_TRANSFORM:"KHR_texture_transform",KHR_MESH_QUANTIZATION:"KHR_mesh_quantization",KHR_MATERIALS_EMISSIVE_STRENGTH:"KHR_materials_emissive_strength",EXT_MATERIALS_BUMP:"EXT_materials_bump",EXT_TEXTURE_WEBP:"EXT_texture_webp",EXT_TEXTURE_AVIF:"EXT_texture_avif",EXT_MESHOPT_COMPRESSION:"EXT_meshopt_compression",KHR_MESHOPT_COMPRESSION:"KHR_meshopt_compression",EXT_MESH_GPU_INSTANCING:"EXT_mesh_gpu_instancing"},du=class{constructor(t){this.parser=t,this.name=Wt.KHR_LIGHTS_PUNCTUAL,this.cache={refs:{},uses:{}}}_markDefs(){let t=this.parser,e=this.parser.json.nodes||[];for(let n=0,i=e.length;n<i;n++){let r=e[n];r.extensions&&r.extensions[this.name]&&r.extensions[this.name].light!==void 0&&t._addNodeRef(this.cache,r.extensions[this.name].light)}}_loadLight(t){let e=this.parser,n="light:"+t,i=e.cache.get(n);if(i)return i;let r=e.json,c=((r.extensions&&r.extensions[this.name]||{}).lights||[])[t],l,h=new Pt(16777215);c.color!==void 0&&h.setRGB(c.color[0],c.color[1],c.color[2],Ke);let f=c.range!==void 0?c.range:0;switch(c.type){case"directional":l=new bs(h),l.target.position.set(0,0,-1),l.add(l.target);break;case"point":l=new Ss(h),l.distance=f;break;case"spot":l=new Ms(h),l.distance=f,c.spot=c.spot||{},c.spot.innerConeAngle=c.spot.innerConeAngle!==void 0?c.spot.innerConeAngle:0,c.spot.outerConeAngle=c.spot.outerConeAngle!==void 0?c.spot.outerConeAngle:Math.PI/4,l.angle=c.spot.outerConeAngle,l.penumbra=1-c.spot.innerConeAngle/c.spot.outerConeAngle,l.target.position.set(0,0,-1),l.add(l.target);break;default:throw new Error("THREE.GLTFLoader: Unexpected light type: "+c.type)}return l.position.set(0,0,0),li(l,c),c.intensity!==void 0&&(l.intensity=c.intensity),l.name=e.createUniqueName(c.name||"light_"+t),i=Promise.resolve(l),e.cache.add(n,i),i}getDependency(t,e){if(t==="light")return this._loadLight(e)}createNodeAttachment(t){let e=this,n=this.parser,r=n.json.nodes[t],a=(r.extensions&&r.extensions[this.name]||{}).light;return a===void 0?null:this._loadLight(a).then(function(c){return n._getNodeRef(e.cache,a,c)})}},pu=class{constructor(){this.name=Wt.KHR_MATERIALS_UNLIT}getMaterialType(){return Oe}extendParams(t,e,n){let i=[];t.color=new Pt(1,1,1),t.opacity=1;let r=e.pbrMetallicRoughness;if(r){if(Array.isArray(r.baseColorFactor)){let o=r.baseColorFactor;t.color.setRGB(o[0],o[1],o[2],Ke),t.opacity=o[3]}r.baseColorTexture!==void 0&&i.push(n.assignTexture(t,"map",r.baseColorTexture,ee))}return Promise.all(i)}},mu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_EMISSIVE_STRENGTH}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);return n===null||n.emissiveStrength!==void 0&&(e.emissiveIntensity=n.emissiveStrength),Promise.resolve()}},gu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_CLEARCOAT}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];if(n.clearcoatFactor!==void 0&&(e.clearcoat=n.clearcoatFactor),n.clearcoatTexture!==void 0&&i.push(this.parser.assignTexture(e,"clearcoatMap",n.clearcoatTexture)),n.clearcoatRoughnessFactor!==void 0&&(e.clearcoatRoughness=n.clearcoatRoughnessFactor),n.clearcoatRoughnessTexture!==void 0&&i.push(this.parser.assignTexture(e,"clearcoatRoughnessMap",n.clearcoatRoughnessTexture)),n.clearcoatNormalTexture!==void 0&&(i.push(this.parser.assignTexture(e,"clearcoatNormalMap",n.clearcoatNormalTexture)),n.clearcoatNormalTexture.scale!==void 0)){let r=n.clearcoatNormalTexture.scale;e.clearcoatNormalScale=new At(r,r)}return Promise.all(i)}},_u=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_DIFFUSE_ROUGHNESS}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];return e.diffuseRoughness=n.diffuseRoughnessFactor!==void 0?n.diffuseRoughnessFactor:0,n.diffuseRoughnessTexture!==void 0&&i.push(this.parser.assignTexture(e,"diffuseRoughnessMap",n.diffuseRoughnessTexture)),Promise.all(i)}},xu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_DISPERSION}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);return n===null||(e.dispersion=n.dispersion!==void 0?n.dispersion:0),Promise.resolve()}},yu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_IRIDESCENCE}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];return n.iridescenceFactor!==void 0&&(e.iridescence=n.iridescenceFactor),n.iridescenceTexture!==void 0&&i.push(this.parser.assignTexture(e,"iridescenceMap",n.iridescenceTexture)),n.iridescenceIor!==void 0&&(e.iridescenceIOR=n.iridescenceIor),n.iridescenceThicknessMinimum!==void 0&&(e.iridescenceThicknessMinimum=n.iridescenceThicknessMinimum),n.iridescenceThicknessMaximum!==void 0&&(e.iridescenceThicknessMaximum=n.iridescenceThicknessMaximum),n.iridescenceThicknessTexture!==void 0&&i.push(this.parser.assignTexture(e,"iridescenceThicknessMap",n.iridescenceThicknessTexture)),Promise.all(i)}},vu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_SHEEN}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];if(e.sheenColor=new Pt(0,0,0),e.sheenRoughness=0,e.sheen=1,n.sheenColorFactor!==void 0){let r=n.sheenColorFactor;e.sheenColor.setRGB(r[0],r[1],r[2],Ke)}return n.sheenRoughnessFactor!==void 0&&(e.sheenRoughness=n.sheenRoughnessFactor),n.sheenColorTexture!==void 0&&i.push(this.parser.assignTexture(e,"sheenColorMap",n.sheenColorTexture,ee)),n.sheenRoughnessTexture!==void 0&&i.push(this.parser.assignTexture(e,"sheenRoughnessMap",n.sheenRoughnessTexture)),Promise.all(i)}},Mu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_TRANSMISSION}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];return n.transmissionFactor!==void 0&&(e.transmission=n.transmissionFactor),n.transmissionTexture!==void 0&&i.push(this.parser.assignTexture(e,"transmissionMap",n.transmissionTexture)),Promise.all(i)}},Su=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_VOLUME}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];e.thickness=n.thicknessFactor!==void 0?n.thicknessFactor:0,n.thicknessTexture!==void 0&&i.push(this.parser.assignTexture(e,"thicknessMap",n.thicknessTexture)),e.attenuationDistance=n.attenuationDistance||1/0;let r=n.attenuationColor||[1,1,1];return e.attenuationColor=new Pt().setRGB(r[0],r[1],r[2],Ke),Promise.all(i)}},bu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_IOR}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);return n===null||(e.ior=n.ior!==void 0?n.ior:1.5,e.ior===0&&(e.ior=1e3)),Promise.resolve()}},Tu=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_SPECULAR}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];e.specularIntensity=n.specularFactor!==void 0?n.specularFactor:1,n.specularTexture!==void 0&&i.push(this.parser.assignTexture(e,"specularIntensityMap",n.specularTexture));let r=n.specularColorFactor||[1,1,1];return e.specularColor=new Pt().setRGB(r[0],r[1],r[2],Ke),n.specularColorTexture!==void 0&&i.push(this.parser.assignTexture(e,"specularColorMap",n.specularColorTexture,ee)),Promise.all(i)}},wu=class{constructor(t){this.parser=t,this.name=Wt.EXT_MATERIALS_BUMP}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];return e.bumpScale=n.bumpFactor!==void 0?n.bumpFactor:1,n.bumpTexture!==void 0&&i.push(this.parser.assignTexture(e,"bumpMap",n.bumpTexture)),Promise.all(i)}},Au=class{constructor(t){this.parser=t,this.name=Wt.KHR_MATERIALS_ANISOTROPY}getMaterialType(t){return Re(this.parser,t,this.name)!==null?dn:null}extendMaterialParams(t,e){let n=Re(this.parser,t,this.name);if(n===null)return Promise.resolve();let i=[];return n.anisotropyStrength!==void 0&&(e.anisotropy=n.anisotropyStrength),n.anisotropyRotation!==void 0&&(e.anisotropyRotation=n.anisotropyRotation),n.anisotropyTexture!==void 0&&i.push(this.parser.assignTexture(e,"anisotropyMap",n.anisotropyTexture)),Promise.all(i)}},Eu=class{constructor(t){this.parser=t,this.name=Wt.KHR_TEXTURE_BASISU}loadTexture(t){let e=this.parser,n=e.json,i=n.textures[t];if(!i.extensions||!i.extensions[this.name])return null;let r=i.extensions[this.name],o=e.options.ktx2Loader;if(!o){if(n.extensionsRequired&&n.extensionsRequired.indexOf(this.name)>=0)throw new Error("THREE.GLTFLoader: setKTX2Loader must be called before loading KTX2 textures");return null}return e.loadTextureImage(t,r.source,o)}},Ru=class{constructor(t){this.parser=t,this.name=Wt.EXT_TEXTURE_WEBP}loadTexture(t){let e=this.name,n=this.parser,i=n.json,r=i.textures[t];if(!r.extensions||!r.extensions[e])return null;let o=r.extensions[e],a=i.images[o.source],c=n.textureLoader;if(a.uri){let l=n.options.manager.getHandler(a.uri);l!==null&&(c=l)}return n.loadTextureImage(t,o.source,c)}},Cu=class{constructor(t){this.parser=t,this.name=Wt.EXT_TEXTURE_AVIF}loadTexture(t){let e=this.name,n=this.parser,i=n.json,r=i.textures[t];if(!r.extensions||!r.extensions[e])return null;let o=r.extensions[e],a=i.images[o.source],c=n.textureLoader;if(a.uri){let l=n.options.manager.getHandler(a.uri);l!==null&&(c=l)}return n.loadTextureImage(t,o.source,c)}},$c=class{constructor(t,e){this.name=e,this.parser=t}loadBufferView(t){let e=this.parser.json,n=e.bufferViews[t];if(n.extensions&&n.extensions[this.name]){let i=n.extensions[this.name],r=this.parser.getDependency("buffer",i.buffer),o=this.parser.options.meshoptDecoder;if(!o||!o.supported){if(e.extensionsRequired&&e.extensionsRequired.indexOf(this.name)>=0)throw new Error("THREE.GLTFLoader: setMeshoptDecoder must be called before loading compressed files");return null}return r.then(function(a){let c=i.byteOffset||0,l=i.byteLength||0,h=i.count,f=i.byteStride,u=new Uint8Array(a,c,l);return o.decodeGltfBufferAsync?o.decodeGltfBufferAsync(h,f,u,i.mode,i.filter).then(function(d){return d.buffer}):o.ready.then(function(){let d=new ArrayBuffer(h*f);return o.decodeGltfBuffer(new Uint8Array(d),h,f,u,i.mode,i.filter),d})})}else return null}},Pu=class{constructor(t){this.name=Wt.EXT_MESH_GPU_INSTANCING,this.parser=t}createNodeMesh(t){let e=this.parser.json,n=e.nodes[t];if(!n.extensions||!n.extensions[this.name]||n.mesh===void 0)return null;let i=e.meshes[n.mesh];for(let l of i.primitives)if(l.mode!==On.TRIANGLES&&l.mode!==On.TRIANGLE_STRIP&&l.mode!==On.TRIANGLE_FAN&&l.mode!==void 0)return null;let o=n.extensions[this.name].attributes,a=[],c={};for(let l in o)a.push(this.parser.getDependency("accessor",o[l]).then(h=>(c[l]=h,c[l])));return a.length<1?null:(a.push(this.parser.createNodeMesh(t)),Promise.all(a).then(l=>{let h=l.pop(),f=h.isGroup?h.children:[h],u=l[0].count,d=[];for(let g of f){let v=new _t,m=new R,p=new wn,x=new R(1,1,1),M=new ys(g.geometry,g.material,u);for(let S=0;S<u;S++)c.TRANSLATION&&m.fromBufferAttribute(c.TRANSLATION,S),c.ROTATION&&p.fromBufferAttribute(c.ROTATION,S),c.SCALE&&x.fromBufferAttribute(c.SCALE,S),M.setMatrixAt(S,v.compose(m,p,x));let y=null;for(let S in c)if(S==="_COLOR_0"){let T=c[S];M.instanceColor=new wi(T.array,T.itemSize,T.normalized)}else if(S!=="TRANSLATION"&&S!=="ROTATION"&&S!=="SCALE"){if(y===null){let _=M.geometry;y=new ye,y.name=_.name;for(let b in _.attributes)y.setAttribute(b,_.attributes[b]);for(let b in _.morphAttributes)y.morphAttributes[b]=_.morphAttributes[b];_.index!==null&&y.setIndex(_.index),y.morphTargetsRelative=_.morphTargetsRelative;for(let b of _.groups)y.addGroup(b.start,b.count,b.materialIndex);_.boundingBox!==null&&(y.boundingBox=_.boundingBox.clone()),_.boundingSphere!==null&&(y.boundingSphere=_.boundingSphere.clone()),y.drawRange.start=_.drawRange.start,y.drawRange.count=_.drawRange.count,y.userData=Object.assign({},_.userData),M.geometry=y}let T=c[S];y.setAttribute(S,new wi(T.array,T.itemSize,T.normalized))}Ae.prototype.copy.call(M,g),this.parser.assignFinalMaterial(M),d.push(M)}return h.isGroup?(h.clear(),h.add(...d),h):d[0]}))}},zp="glTF",Ho=12,Up={JSON:1313821514,BIN:5130562},Iu=class{constructor(t){this.name=Wt.KHR_BINARY_GLTF,this.content=null,this.body=null;let e=new DataView(t,0,Ho),n=new TextDecoder;if(this.header={magic:n.decode(new Uint8Array(t.slice(0,4))),version:e.getUint32(4,!0),length:e.getUint32(8,!0)},this.header.magic!==zp)throw new Error("THREE.GLTFLoader: Unsupported glTF-Binary header.");if(this.header.version<2)throw new Error("THREE.GLTFLoader: Legacy binary file detected.");let i=this.header.length-Ho,r=new DataView(t,Ho),o=0;for(;o<i;){let a=r.getUint32(o,!0);o+=4;let c=r.getUint32(o,!0);if(o+=4,c===Up.JSON){let l=new Uint8Array(t,Ho+o,a);this.content=n.decode(l)}else if(c===Up.BIN){let l=Ho+o;this.body=t.slice(l,l+a)}o+=a}if(this.content===null)throw new Error("THREE.GLTFLoader: JSON content not found.")}},Lu=class{constructor(t,e){if(!e)throw new Error("THREE.GLTFLoader: No DRACOLoader instance provided.");this.name=Wt.KHR_DRACO_MESH_COMPRESSION,this.json=t,this.dracoLoader=e,this.dracoLoader.preload()}decodePrimitive(t,e){let n=this.json,i=this.dracoLoader,r=t.extensions[this.name].bufferView,o=t.extensions[this.name].attributes,a={},c={},l={};for(let h in o){let f=Fu[h]||h.toLowerCase();a[f]=o[h]}for(let h in t.attributes){let f=Fu[h]||h.toLowerCase();if(o[h]!==void 0){let u=n.accessors[t.attributes[h]],d=Rr[u.componentType];l[f]=d.name,c[f]=u.normalized===!0}}return e.getDependency("bufferView",r).then(function(h){return new Promise(function(f,u){i.decodeDracoFile(h,function(d){for(let g in d.attributes){let v=d.attributes[g],m=c[g];m!==void 0&&(v.normalized=m)}f(d)},a,l,Ke,u)})})}},Nu=class{constructor(){this.name=Wt.KHR_TEXTURE_TRANSFORM}extendTexture(t,e){if((e.texCoord===void 0||e.texCoord===t.channel)&&e.offset===void 0&&e.rotation===void 0&&e.scale===void 0)return t;if(t=t.clone(),e.texCoord!==void 0&&(t.channel=e.texCoord),e.offset!==void 0&&t.offset.fromArray(e.offset),e.rotation!==void 0&&(t.rotation=e.rotation),e.scale!==void 0&&t.repeat.fromArray(e.scale),e.rotation!==void 0){let n=Math.cos(t.rotation),i=Math.sin(t.rotation);t.matrix.set(t.repeat.x*n,t.repeat.y*i,t.offset.x,-t.repeat.x*i,t.repeat.y*n,t.offset.y,0,0,1),t.matrixAutoUpdate=!1}return t.needsUpdate=!0,t}},Du=class{constructor(){this.name=Wt.KHR_MESH_QUANTIZATION}},jc=class extends ni{constructor(t,e,n,i){super(t,e,n,i)}copySampleValue_(t){let e=this.resultBuffer,n=this.sampleValues,i=this.valueSize,r=t*i*3+i;for(let o=0;o!==i;o++)e[o]=n[r+o];return e}interpolate_(t,e,n,i){let r=this.resultBuffer,o=this.sampleValues,a=this.valueSize,c=a*2,l=a*3,h=i-e,f=(n-e)/h,u=f*f,d=u*f,g=t*l,v=g-l,m=-2*d+3*u,p=d-u,x=1-m,M=p-u+f;for(let y=0;y!==a;y++){let S=o[v+y+a],T=o[v+y+c]*h,_=o[g+y+a],b=o[g+y]*h;r[y]=x*S+M*T+m*_+p*b}return r}},Iv=new wn,Uu=class extends jc{interpolate_(t,e,n,i){let r=super.interpolate_(t,e,n,i);return Iv.fromArray(r).normalize().toArray(r),r}},On={FLOAT:5126,FLOAT_MAT3:35675,FLOAT_MAT4:35676,FLOAT_VEC2:35664,FLOAT_VEC3:35665,FLOAT_VEC4:35666,LINEAR:9729,REPEAT:10497,SAMPLER_2D:35678,POINTS:0,LINES:1,LINE_LOOP:2,LINE_STRIP:3,TRIANGLES:4,TRIANGLE_STRIP:5,TRIANGLE_FAN:6,UNSIGNED_BYTE:5121,UNSIGNED_SHORT:5123},Rr={5120:Int8Array,5121:Uint8Array,5122:Int16Array,5123:Uint16Array,5125:Uint32Array,5126:Float32Array},Fp={9728:xe,9729:we,9984:sc,9985:br,9986:Es,9987:Sn},Op={33071:xn,33648:er,10497:Hn},hu={SCALAR:1,VEC2:2,VEC3:3,VEC4:4,MAT2:4,MAT3:9,MAT4:16},Fu={POSITION:"position",NORMAL:"normal",TANGENT:"tangent",TEXCOORD_0:"uv",TEXCOORD_1:"uv1",TEXCOORD_2:"uv2",TEXCOORD_3:"uv3",COLOR_0:"color",WEIGHTS_0:"skinWeight",JOINTS_0:"skinIndex"},ji={scale:"scale",translation:"position",rotation:"quaternion",weights:"morphTargetInfluences"},Lv={CUBICSPLINE:void 0,LINEAR:gs,STEP:ms},uu={OPAQUE:"OPAQUE",MASK:"MASK",BLEND:"BLEND"};function Nv(s){return s.DefaultMaterial===void 0&&(s.DefaultMaterial=new Xn({color:16777215,emissive:0,metalness:1,roughness:1,transparent:!1,depthTest:!0,side:pn})),s.DefaultMaterial}function Ls(s,t,e){for(let n in e.extensions)s[n]===void 0&&(t.userData.gltfExtensions=t.userData.gltfExtensions||{},t.userData.gltfExtensions[n]=e.extensions[n])}function li(s,t){t.extras!==void 0&&(typeof t.extras=="object"?Object.assign(s.userData,t.extras):console.warn("THREE.GLTFLoader: Ignoring primitive type .extras, "+t.extras))}function Dv(s,t,e){let n=!1,i=!1,r=!1;for(let l=0,h=t.length;l<h;l++){let f=t[l];if(f.POSITION!==void 0&&(n=!0),f.NORMAL!==void 0&&(i=!0),f.COLOR_0!==void 0&&(r=!0),n&&i&&r)break}if(!n&&!i&&!r)return Promise.resolve(s);let o=[],a=[],c=[];for(let l=0,h=t.length;l<h;l++){let f=t[l];if(n){let u=f.POSITION!==void 0?e.getDependency("accessor",f.POSITION):s.attributes.position;o.push(u)}if(i){let u=f.NORMAL!==void 0?e.getDependency("accessor",f.NORMAL):s.attributes.normal;a.push(u)}if(r){let u=f.COLOR_0!==void 0?e.getDependency("accessor",f.COLOR_0):s.attributes.color;c.push(u)}}return Promise.all([Promise.all(o),Promise.all(a),Promise.all(c)]).then(function(l){let h=l[0],f=l[1],u=l[2];return n&&(s.morphAttributes.position=h),i&&(s.morphAttributes.normal=f),r&&(s.morphAttributes.color=u),s.morphTargetsRelative=!0,s})}function Uv(s,t){if(s.updateMorphTargets(),t.weights!==void 0)for(let e=0,n=t.weights.length;e<n;e++)s.morphTargetInfluences[e]=t.weights[e];if(t.extras&&Array.isArray(t.extras.targetNames)){let e=t.extras.targetNames;if(s.morphTargetInfluences.length===e.length){s.morphTargetDictionary={};for(let n=0,i=e.length;n<i;n++)s.morphTargetDictionary[e[n]]=n}else console.warn("THREE.GLTFLoader: Invalid extras.targetNames length. Ignoring names.")}}function Fv(s){let t,e=s.extensions&&s.extensions[Wt.KHR_DRACO_MESH_COMPRESSION];if(e?t="draco:"+e.bufferView+":"+e.indices+":"+fu(e.attributes):t=s.indices+":"+fu(s.attributes)+":"+s.mode,s.targets!==void 0)for(let n=0,i=s.targets.length;n<i;n++)t+=":"+fu(s.targets[n]);return t}function fu(s){let t="",e=Object.keys(s).sort();for(let n=0,i=e.length;n<i;n++)t+=e[n]+":"+s[e[n]]+";";return t}function Ou(s){switch(s){case Int8Array:return 1/127;case Uint8Array:return 1/255;case Int16Array:return 1/32767;case Uint16Array:return 1/65535;default:throw new Error("THREE.GLTFLoader: Unsupported normalized accessor component type.")}}function Ov(s){return s.search(/\.jpe?g($|\?)/i)>0||s.search(/^data\:image\/jpeg/)===0?"image/jpeg":s.search(/\.webp($|\?)/i)>0||s.search(/^data\:image\/webp/)===0?"image/webp":s.search(/\.ktx2($|\?)/i)>0||s.search(/^data\:image\/ktx2/)===0?"image/ktx2":"image/png"}var Bv=new _t,Bu=class{constructor(t={},e={}){this.json=t,this.extensions={},this.plugins={},this.options=e,this.cache=new Pv,this.associations=new Map,this.primitiveCache={},this.nodeCache={},this.meshCache={refs:{},uses:{}},this.cameraCache={refs:{},uses:{}},this.lightCache={refs:{},uses:{}},this.sourceCache={},this.textureCache={},this.nodeNamesUsed={};let n=!1,i=-1,r=!1,o=-1;if(typeof navigator<"u"&&typeof navigator.userAgent<"u"){let a=navigator.userAgent;n=/^((?!chrome|android).)*safari/i.test(a)===!0;let c=a.match(/Version\/(\d+)/);i=n&&c?parseInt(c[1],10):-1,r=a.indexOf("Firefox")>-1,o=r?a.match(/Firefox\/([0-9]+)\./)[1]:-1}typeof createImageBitmap>"u"||n&&i<17||r&&o<98?(this.textureLoader=new si(this.options.manager),this.textureLoader.setPriority(this.options.priority),this.textureLoader.setCache(this.options.cache)):(this.textureLoader=new To(this.options.manager),this.textureLoader.setPriority(this.options.priority),this.textureLoader.setCache(this.options.cache)),this.textureLoader.setCrossOrigin(this.options.crossOrigin),this.textureLoader.setWithCredentials(this.options.withCredentials),this.textureLoader.setRequestHeader(this.options.requestHeader),this.fileLoader=new gr(this.options.manager),this.fileLoader.setPriority(this.options.priority),this.fileLoader.setCache(this.options.cache),this.fileLoader.setResponseType("arraybuffer"),(this.options.withCredentials||this.options.crossOrigin==="use-credentials")&&this.fileLoader.setWithCredentials(!0)}setExtensions(t){this.extensions=t}setPlugins(t){this.plugins=t}parse(t,e){let n=this,i=this.json,r=this.extensions;this.cache.removeAll(),this.nodeCache={},this._invokeAll(function(o){return o._markDefs&&o._markDefs()}),Promise.all(this._invokeAll(function(o){return o.beforeRoot&&o.beforeRoot()})).then(function(){return Promise.all([n.getDependencies("scene"),n.getDependencies("animation"),n.getDependencies("camera")])}).then(function(o){let a={scene:o[0][i.scene||0],scenes:o[0],animations:o[1],cameras:o[2],asset:i.asset,parser:n,userData:{}};return Ls(r,a,i),li(a,i),Promise.all(n._invokeAll(function(c){return c.afterRoot&&c.afterRoot(a)})).then(function(){for(let c of a.scenes)c.updateMatrixWorld();t(a)})}).catch(e)}_markDefs(){let t=this.json.nodes||[],e=this.json.skins||[],n=this.json.meshes||[];for(let i=0,r=e.length;i<r;i++){let o=e[i].joints;for(let a=0,c=o.length;a<c;a++)t[o[a]].isBone=!0}for(let i=0,r=t.length;i<r;i++){let o=t[i];o.mesh!==void 0&&(this._addNodeRef(this.meshCache,o.mesh),o.skin!==void 0&&(n[o.mesh].isSkinnedMesh=!0)),o.camera!==void 0&&this._addNodeRef(this.cameraCache,o.camera)}}_addNodeRef(t,e){e!==void 0&&(t.refs[e]===void 0&&(t.refs[e]=t.uses[e]=0),t.refs[e]++)}_getNodeRef(t,e,n){if(t.refs[e]<=1)return n;let i=n.clone(),r=(o,a)=>{let c=this.associations.get(o);c!=null&&this.associations.set(a,c);for(let[l,h]of o.children.entries())r(h,a.children[l])};return r(n,i),i.name+="_instance_"+t.uses[e]++,i}_invokeOne(t){let e=Object.values(this.plugins);e.push(this);for(let n=0;n<e.length;n++){let i=t(e[n]);if(i)return i}return null}_invokeAll(t){let e=Object.values(this.plugins);e.unshift(this);let n=[];for(let i=0;i<e.length;i++){let r=t(e[i]);r&&n.push(r)}return n}getDependency(t,e){let n=t+":"+e,i=this.cache.get(n);if(!i){switch(t){case"scene":i=this.loadScene(e);break;case"node":i=this._invokeOne(function(r){return r.loadNode&&r.loadNode(e)});break;case"mesh":i=this._invokeOne(function(r){return r.loadMesh&&r.loadMesh(e)});break;case"accessor":i=this.loadAccessor(e);break;case"bufferView":i=this._invokeOne(function(r){return r.loadBufferView&&r.loadBufferView(e)});break;case"buffer":i=this.loadBuffer(e);break;case"material":i=this._invokeOne(function(r){return r.loadMaterial&&r.loadMaterial(e)});break;case"texture":i=this._invokeOne(function(r){return r.loadTexture&&r.loadTexture(e)});break;case"skin":i=this.loadSkin(e);break;case"animation":i=this._invokeOne(function(r){return r.loadAnimation&&r.loadAnimation(e)});break;case"camera":i=this.loadCamera(e);break;default:if(i=this._invokeOne(function(r){return r!=this&&r.getDependency&&r.getDependency(t,e)}),!i)throw new Error("Unknown type: "+t);break}this.cache.add(n,i)}return i}getDependencies(t){let e=this.cache.get(t);if(!e){let n=this,i=this.json[t+(t==="mesh"?"es":"s")]||[];e=Promise.all(i.map(function(r,o){return n.getDependency(t,o)})),this.cache.add(t,e)}return e}loadBuffer(t){let e=this.json.buffers[t],n=this.fileLoader;if(e.type&&e.type!=="arraybuffer")throw new Error("THREE.GLTFLoader: "+e.type+" buffer type is not supported.");if(e.uri===void 0&&t===0)return Promise.resolve(this.extensions[Wt.KHR_BINARY_GLTF].body);let i=this.options;return new Promise(function(r,o){n.load(Ni.resolveURL(e.uri,i.path),r,void 0,function(){o(new Error('THREE.GLTFLoader: Failed to load buffer "'+e.uri+'".'))})})}loadBufferView(t){let e=this.json.bufferViews[t];return this.getDependency("buffer",e.buffer).then(function(n){let i=e.byteLength||0,r=e.byteOffset||0;return n.slice(r,r+i)})}loadAccessor(t){let e=this,n=this.json,i=this.json.accessors[t];if(i.bufferView===void 0&&i.sparse===void 0){let o=hu[i.type],a=Rr[i.componentType],c=i.normalized===!0,l=new a(i.count*o);return Promise.resolve(new Te(l,o,c))}let r=[];return i.bufferView!==void 0?r.push(this.getDependency("bufferView",i.bufferView)):r.push(null),i.sparse!==void 0&&(r.push(this.getDependency("bufferView",i.sparse.indices.bufferView)),r.push(this.getDependency("bufferView",i.sparse.values.bufferView))),Promise.all(r).then(function(o){let a=o[0],c=hu[i.type],l=Rr[i.componentType],h=l.BYTES_PER_ELEMENT,f=h*c,u=i.byteOffset||0,d=i.bufferView!==void 0?n.bufferViews[i.bufferView].byteStride:void 0,g=i.normalized===!0,v,m;if(d&&d!==f){let p=Math.floor(u/d),x="InterleavedBuffer:"+i.bufferView+":"+i.componentType+":"+p+":"+i.count,M=e.cache.get(x);M||(v=new l(a,p*d,i.count*d/h),M=new cr(v,d/h),e.cache.add(x,M)),m=new lr(M,c,u%d/h,g)}else a===null?v=new l(i.count*c):v=new l(a,u,i.count*c),m=new Te(v,c,g);if(i.sparse!==void 0){let p=hu.SCALAR,x=Rr[i.sparse.indices.componentType],M=i.sparse.indices.byteOffset||0,y=i.sparse.values.byteOffset||0,S=new x(o[1],M,i.sparse.count*p),T=new l(o[2],y,i.sparse.count*c);a!==null&&(m=new Te(m.array.slice(),m.itemSize,m.normalized)),m.normalized=!1;for(let _=0,b=S.length;_<b;_++){let I=S[_];if(m.setX(I,T[_*c]),c>=2&&m.setY(I,T[_*c+1]),c>=3&&m.setZ(I,T[_*c+2]),c>=4&&m.setW(I,T[_*c+3]),c>=5)throw new Error("THREE.GLTFLoader: Unsupported itemSize in sparse BufferAttribute.")}m.normalized=g}return m})}loadTexture(t){let e=this.json,n=this.options,r=e.textures[t].source,o=e.images[r],a=this.textureLoader;if(o.uri){let c=n.manager.getHandler(o.uri);c!==null&&(a=c)}return this.loadTextureImage(t,r,a)}loadTextureImage(t,e,n){let i=this,r=this.json,o=r.textures[t],a=r.images[e],c=(a.uri||a.bufferView)+":"+o.sampler;if(this.textureCache[c])return this.textureCache[c];let l=this.loadImageSource(e,n).then(function(h){h.flipY=!1,h.name=o.name||a.name||"",h.name===""&&typeof a.uri=="string"&&a.uri.startsWith("data:image/")===!1&&(h.name=a.uri);let u=(r.samplers||{})[o.sampler]||{};return h.magFilter=Fp[u.magFilter]||we,h.minFilter=Fp[u.minFilter]||Sn,h.wrapS=Op[u.wrapS]||Hn,h.wrapT=Op[u.wrapT]||Hn,h.generateMipmaps=!h.isCompressedTexture&&h.minFilter!==xe&&h.minFilter!==we,i.associations.set(h,{textures:t}),h}).catch(function(){return null});return this.textureCache[c]=l,l}loadImageSource(t,e){let n=this,i=this.json,r=this.options;if(this.sourceCache[t]!==void 0)return this.sourceCache[t].then(u=>u.clone());let o=i.images[t],a=self.URL||self.webkitURL,c=o.uri||"",l=!1,h;if(e.isKTX2Loader===!0&&o.bufferView!==void 0)h=n.getDependency("bufferView",o.bufferView).then(function(u){return new Promise(function(d,g){e.parse(u,d,g)})});else{if(o.bufferView!==void 0)c=n.getDependency("bufferView",o.bufferView).then(function(u){l=!0;let d=new Blob([u],{type:o.mimeType});return c=a.createObjectURL(d),c});else if(o.uri===void 0)throw new Error("THREE.GLTFLoader: Image "+t+" is missing URI and bufferView");h=Promise.resolve(c).then(function(u){return new Promise(function(d,g){let v=d;e.isImageBitmapLoader===!0&&(v=function(m){let p=new ke(m);p.needsUpdate=!0,d(p)}),e.load(Ni.resolveURL(u,r.path),v,void 0,g)})})}let f=h.then(function(u){return l===!0&&a.revokeObjectURL(c),li(u,o),u.userData.mimeType=o.mimeType||Ov(o.uri),u}).catch(function(u){throw console.error("THREE.GLTFLoader: Couldn't load texture",c),u});return this.sourceCache[t]=f,f}assignTexture(t,e,n,i){let r=this;return this.getDependency("texture",n.index).then(function(o){if(!o)return null;if(n.texCoord!==void 0&&n.texCoord>0&&(o=o.clone(),o.channel=n.texCoord),r.extensions[Wt.KHR_TEXTURE_TRANSFORM]){let a=n.extensions!==void 0?n.extensions[Wt.KHR_TEXTURE_TRANSFORM]:void 0;if(a){let c=r.associations.get(o);o=r.extensions[Wt.KHR_TEXTURE_TRANSFORM].extendTexture(o,a),r.associations.set(o,c)}}return i!==void 0&&(o.colorSpace=i),t[e]=o,o})}assignFinalMaterial(t){let e=t.geometry,n=t.material,i=e.attributes.tangent===void 0,r=e.attributes.color!==void 0,o=e.attributes.normal===void 0;if(t.isPoints){let a="PointsMaterial:"+n.uuid,c=this.cache.get(a);c||(c=new fr,vn.prototype.copy.call(c,n),c.color.copy(n.color),c.map=n.map,c.sizeAttenuation=!1,this.cache.add(a,c)),n=c}else if(t.isLine){let a="LineBasicMaterial:"+n.uuid,c=this.cache.get(a);c||(c=new Wn,vn.prototype.copy.call(c,n),c.color.copy(n.color),c.map=n.map,this.cache.add(a,c)),n=c}if(i||r||o){let a="ClonedMaterial:"+n.uuid+":";i&&(a+="derivative-tangents:"),r&&(a+="vertex-colors:"),o&&(a+="flat-shading:");let c=this.cache.get(a);c||(c=n.clone(),r&&(c.vertexColors=!0),o&&(c.flatShading=!0),i&&(c.normalScale&&(c.normalScale.y*=-1),c.clearcoatNormalScale&&(c.clearcoatNormalScale.y*=-1)),this.cache.add(a,c),this.associations.set(c,this.associations.get(n))),n=c}t.material=n}getMaterialType(){return Xn}loadMaterial(t){let e=this,n=this.json,i=this.extensions,r=n.materials[t],o,a={},c=r.extensions||{},l=[];if(c[Wt.KHR_MATERIALS_UNLIT]){let f=i[Wt.KHR_MATERIALS_UNLIT];o=f.getMaterialType(),l.push(f.extendParams(a,r,e))}else{let f=r.pbrMetallicRoughness||{};if(a.color=new Pt(1,1,1),a.opacity=1,Array.isArray(f.baseColorFactor)){let u=f.baseColorFactor;a.color.setRGB(u[0],u[1],u[2],Ke),a.opacity=u[3]}f.baseColorTexture!==void 0&&l.push(e.assignTexture(a,"map",f.baseColorTexture,ee)),a.metalness=f.metallicFactor!==void 0?f.metallicFactor:1,a.roughness=f.roughnessFactor!==void 0?f.roughnessFactor:1,f.metallicRoughnessTexture!==void 0&&(l.push(e.assignTexture(a,"metalnessMap",f.metallicRoughnessTexture)),l.push(e.assignTexture(a,"roughnessMap",f.metallicRoughnessTexture))),o=this._invokeOne(function(u){return u.getMaterialType&&u.getMaterialType(t)}),l.push(Promise.all(this._invokeAll(function(u){return u.extendMaterialParams&&u.extendMaterialParams(t,a)})))}r.doubleSided===!0&&(a.side=Pe);let h=r.alphaMode||uu.OPAQUE;if(h===uu.BLEND?(a.transparent=!0,a.depthWrite=!1):(a.transparent=!1,h===uu.MASK&&(a.alphaTest=r.alphaCutoff!==void 0?r.alphaCutoff:.5)),r.normalTexture!==void 0&&o!==Oe&&(l.push(e.assignTexture(a,"normalMap",r.normalTexture)),a.normalScale=new At(1,1),r.normalTexture.scale!==void 0)){let f=r.normalTexture.scale;a.normalScale.set(f,f)}if(r.occlusionTexture!==void 0&&o!==Oe&&(l.push(e.assignTexture(a,"aoMap",r.occlusionTexture)),r.occlusionTexture.strength!==void 0&&(a.aoMapIntensity=r.occlusionTexture.strength)),r.emissiveFactor!==void 0&&o!==Oe){let f=r.emissiveFactor;a.emissive=new Pt().setRGB(f[0],f[1],f[2],Ke)}return r.emissiveTexture!==void 0&&o!==Oe&&l.push(e.assignTexture(a,"emissiveMap",r.emissiveTexture,ee)),Promise.all(l).then(function(){let f=new o(a);return r.name&&(f.name=r.name),li(f,r),e.associations.set(f,{materials:t}),r.extensions&&Ls(i,f,r),f})}createUniqueName(t){let e=ue.sanitizeNodeName(t||"");return e in this.nodeNamesUsed?e+"_"+ ++this.nodeNamesUsed[e]:(this.nodeNamesUsed[e]=0,e)}loadGeometries(t){let e=this,n=this.extensions,i=this.primitiveCache;function r(a){return n[Wt.KHR_DRACO_MESH_COMPRESSION].decodePrimitive(a,e).then(function(c){return Bp(c,a,e)})}let o=[];for(let a=0,c=t.length;a<c;a++){let l=t[a],h=Fv(l),f=i[h];if(f)o.push(f.promise);else{let u;l.extensions&&l.extensions[Wt.KHR_DRACO_MESH_COMPRESSION]?u=r(l):u=Bp(new ye,l,e),l.mode===On.TRIANGLE_STRIP?u=u.then(d=>lu(d,zo)):l.mode===On.TRIANGLE_FAN&&(u=u.then(d=>lu(d,wr))),i[h]={primitive:l,promise:u},o.push(u)}}return Promise.all(o)}loadMesh(t){let e=this,n=this.json,i=this.extensions,r=n.meshes[t],o=r.primitives,a=[];for(let c=0,l=o.length;c<l;c++){let h=o[c].material===void 0?Nv(this.cache):this.getDependency("material",o[c].material);a.push(h)}return a.push(e.loadGeometries(o)),Promise.all(a).then(async function(c){let l=c.slice(0,c.length-1),h=c[c.length-1],f=[];for(let d=0,g=h.length;d<g;d++){let v=h[d],m=o[d],p,x=l[d];if(m.mode===On.TRIANGLES||m.mode===On.TRIANGLE_STRIP||m.mode===On.TRIANGLE_FAN||m.mode===void 0){let M=r.isSkinnedMesh===!0,y=v.hasAttribute("skinIndex")&&v.hasAttribute("skinWeight");M&&y===!1&&console.warn("THREE.GLTFLoader: Missing skinIndex or skinWeight attributes. Skinning disabled."),p=M&&y?new lo(v,x):new Ee(v,x),p.isSkinnedMesh===!0&&p.normalizeSkinWeights()}else if(m.mode===On.LINES)p=new uo(v,x);else if(m.mode===On.LINE_STRIP)p=new Un(v,x);else if(m.mode===On.LINE_LOOP)p=new fo(v,x);else if(m.mode===On.POINTS)p=new po(v,x);else throw new Error("THREE.GLTFLoader: Primitive mode unsupported: "+m.mode);Object.keys(p.geometry.morphAttributes).length>0&&Uv(p,r),p.name=e.createUniqueName(r.name||"mesh_"+t),li(p,r),m.extensions&&Ls(i,p,m),e.assignFinalMaterial(p),f.push(p)}for(let d=0,g=f.length;d<g;d++)e.associations.set(f[d],{meshes:t,primitives:d});if(f.length===1)return r.extensions&&Ls(i,f[0],r),f[0];let u=new Ye;r.extensions&&Ls(i,u,r),e.associations.set(u,{meshes:t});for(let d=0,g=f.length;d<g;d++)u.add(f[d]);return u})}loadCamera(t){let e,n=this.json.cameras[t],i=n[n.type];if(!i){console.warn("THREE.GLTFLoader: Missing camera parameters.");return}return n.type==="perspective"?e=new Le(me.radToDeg(i.yfov),i.aspectRatio||1,i.znear||1,i.zfar||2e6):n.type==="orthographic"&&(e=new qn(-i.xmag,i.xmag,i.ymag,-i.ymag,i.znear,i.zfar)),n.name&&(e.name=this.createUniqueName(n.name)),li(e,n),Promise.resolve(e)}loadSkin(t){let e=this.json.skins[t],n=[];for(let i=0,r=e.joints.length;i<r;i++)n.push(this._loadNodeShallow(e.joints[i]));return e.inverseBindMatrices!==void 0?n.push(this.getDependency("accessor",e.inverseBindMatrices)):n.push(null),Promise.all(n).then(function(i){let r=i.pop(),o=i,a=[],c=[];for(let l=0,h=o.length;l<h;l++){let f=o[l];if(f){a.push(f);let u=new _t;r!==null&&u.fromArray(r.array,l*16),c.push(u)}else console.warn('THREE.GLTFLoader: Joint "%s" could not be found.',e.joints[l])}return new ho(a,c)})}loadAnimation(t){let e=this.json,n=this,i=e.animations[t],r=i.name?i.name:"animation_"+t,o=[],a=[],c=[],l=[],h=[];for(let f=0,u=i.channels.length;f<u;f++){let d=i.channels[f],g=i.samplers[d.sampler],v=d.target,m=v.node,p=i.parameters!==void 0?i.parameters[g.input]:g.input,x=i.parameters!==void 0?i.parameters[g.output]:g.output;v.node!==void 0&&(o.push(this.getDependency("node",m)),a.push(this.getDependency("accessor",p)),c.push(this.getDependency("accessor",x)),l.push(g),h.push(v))}return Promise.all([Promise.all(o),Promise.all(a),Promise.all(c),Promise.all(l),Promise.all(h)]).then(function(f){let u=f[0],d=f[1],g=f[2],v=f[3],m=f[4],p=[];for(let M=0,y=u.length;M<y;M++){let S=u[M],T=d[M],_=g[M],b=v[M],I=m[M];if(S===void 0)continue;S.updateMatrix&&S.updateMatrix();let E=n._createAnimationTracks(S,T,_,b,I);if(E)for(let L=0;L<E.length;L++)p.push(E[L])}let x=new Mo(r,void 0,p);return li(x,i),x})}createNodeMesh(t){let e=this.json,n=this,i=e.nodes[t];return i.mesh===void 0?null:n.getDependency("mesh",i.mesh).then(function(r){let o=n._getNodeRef(n.meshCache,i.mesh,r);return i.weights!==void 0&&o.traverse(function(a){if(a.isMesh)for(let c=0,l=i.weights.length;c<l;c++)a.morphTargetInfluences[c]=i.weights[c]}),o})}loadNode(t){let e=this.json,n=this,i=e.nodes[t],r=n._loadNodeShallow(t),o=[],a=i.children||[];for(let l=0,h=a.length;l<h;l++)o.push(n.getDependency("node",a[l]));let c=i.skin===void 0?Promise.resolve(null):n.getDependency("skin",i.skin);return Promise.all([r,Promise.all(o),c]).then(function(l){let h=l[0],f=l[1],u=l[2];u!==null&&h.traverse(function(d){d.isSkinnedMesh&&d.bind(u,Bv)});for(let d=0,g=f.length;d<g;d++)h.add(f[d]);if(h.userData.pivot!==void 0&&f.length>0){let d=h.userData.pivot,g=f[0];h.pivot=new R().fromArray(d),h.position.x-=d[0],h.position.y-=d[1],h.position.z-=d[2],g.position.set(0,0,0),delete h.userData.pivot}return h})}_loadNodeShallow(t){let e=this.json,n=this.extensions,i=this;if(this.nodeCache[t]!==void 0)return this.nodeCache[t];let r=e.nodes[t],o=r.name?i.createUniqueName(r.name):"",a=[],c=i._invokeOne(function(l){return l.createNodeMesh&&l.createNodeMesh(t)});return c&&a.push(c),r.camera!==void 0&&a.push(i.getDependency("camera",r.camera).then(function(l){return i._getNodeRef(i.cameraCache,r.camera,l)})),i._invokeAll(function(l){return l.createNodeAttachment&&l.createNodeAttachment(t)}).forEach(function(l){a.push(l)}),this.nodeCache[t]=Promise.all(a).then(function(l){let h;if(r.isBone===!0?h=new hr:l.length>1?h=new Ye:l.length===1?h=l[0]:h=new Ae,h!==l[0])for(let f=0,u=l.length;f<u;f++)h.add(l[f]);if(r.name&&(h.userData.name=r.name,h.name=o),li(h,r),r.extensions&&Ls(n,h,r),r.matrix!==void 0){let f=new _t;f.fromArray(r.matrix),h.applyMatrix4(f)}else r.translation!==void 0&&h.position.fromArray(r.translation),r.rotation!==void 0&&h.quaternion.fromArray(r.rotation),r.scale!==void 0&&h.scale.fromArray(r.scale);if(!i.associations.has(h))i.associations.set(h,{});else if(r.mesh!==void 0&&i.meshCache.refs[r.mesh]>1){let f=i.associations.get(h);i.associations.set(h,{...f})}return i.associations.get(h).nodes=t,h}),this.nodeCache[t]}loadScene(t){let e=this.extensions,n=this.json.scenes[t],i=this,r=new Ye;n.name&&(r.name=i.createUniqueName(n.name)),li(r,n),n.extensions&&Ls(e,r,n);let o=n.nodes||[],a=[];for(let c=0,l=o.length;c<l;c++)a.push(i.getDependency("node",o[c]));return Promise.all(a).then(function(c){for(let h=0,f=c.length;h<f;h++){let u=c[h];u.parent!==null?r.add(Np(u)):r.add(u)}let l=h=>{let f=new Map;for(let[u,d]of i.associations)(u instanceof vn||u instanceof ke)&&f.set(u,d);return h.traverse(u=>{let d=i.associations.get(u);d!=null&&f.set(u,d)}),f};return i.associations=l(r),r})}_createAnimationTracks(t,e,n,i,r){let o=[],a=t.name?t.name:t.uuid,c=[];function l(d){d.morphTargetInfluences&&c.push(d.name?d.name:d.uuid)}ji[r.path]===ji.weights?(l(t),t.isGroup&&t.children.forEach(l)):c.push(a);let h;switch(ji[r.path]){case ji.weights:h=Pi;break;case ji.rotation:h=Ii;break;case ji.translation:case ji.scale:h=Zi;break;default:switch(n.itemSize){case 1:h=Pi;break;case 2:case 3:default:h=Zi;break}break}let f=i.interpolation!==void 0?Lv[i.interpolation]:gs,u=this._getArrayFromAccessor(n);for(let d=0,g=c.length;d<g;d++){let v=new h(c[d]+"."+ji[r.path],e.array,u,f);i.interpolation==="CUBICSPLINE"&&this._createCubicSplineTrackInterpolant(v),o.push(v)}return o}_getArrayFromAccessor(t){let e=t.array;if(t.normalized){let n=Ou(e.constructor),i=new Float32Array(e.length);for(let r=0,o=e.length;r<o;r++)i[r]=e[r]*n;e=i}return e}_createCubicSplineTrackInterpolant(t){t.createInterpolant=function(n){let i=this instanceof Ii?Uu:jc;return new i(this.times,this.values,this.getValueSize()/3,n)},t.createInterpolant.isInterpolantFactoryMethodGLTFCubicSpline=!0}};function zv(s,t,e){let n=t.attributes,i=new Jt;if(n.POSITION!==void 0){let a=e.json.accessors[n.POSITION],c=a.min,l=a.max;if(c!==void 0&&l!==void 0){if(i.set(new R(c[0],c[1],c[2]),new R(l[0],l[1],l[2])),a.normalized){let h=Ou(Rr[a.componentType]);i.min.multiplyScalar(h),i.max.multiplyScalar(h)}}else{console.warn("THREE.GLTFLoader: Missing min/max properties for accessor POSITION.");return}}else return;let r=t.targets;if(r!==void 0){let a=new R,c=new R;for(let l=0,h=r.length;l<h;l++){let f=r[l];if(f.POSITION!==void 0){let u=e.json.accessors[f.POSITION],d=u.min,g=u.max;if(d!==void 0&&g!==void 0){if(c.setX(Math.max(Math.abs(d[0]),Math.abs(g[0]))),c.setY(Math.max(Math.abs(d[1]),Math.abs(g[1]))),c.setZ(Math.max(Math.abs(d[2]),Math.abs(g[2]))),u.normalized){let v=Ou(Rr[u.componentType]);c.multiplyScalar(v)}a.max(c)}else console.warn("THREE.GLTFLoader: Missing min/max properties for accessor POSITION.")}}i.expandByVector(a)}s.boundingBox=i;let o=new yn;i.getCenter(o.center),o.radius=i.min.distanceTo(i.max)/2,s.boundingSphere=o}function Bp(s,t,e){let n=t.attributes,i=[];function r(o,a){return e.getDependency("accessor",o).then(function(c){s.setAttribute(a,c)})}for(let o in n){let a=Fu[o]||o.toLowerCase();a in s.attributes||i.push(r(n[o],a))}if(t.indices!==void 0&&!s.index){let o=e.getDependency("accessor",t.indices).then(function(a){s.setIndex(a)});i.push(o)}return Ht.workingColorSpace!==Ke&&"COLOR_0"in n&&console.warn(`THREE.GLTFLoader: Converting vertex colors from "srgb-linear" to "${Ht.workingColorSpace}" not supported.`),li(s,t),zv(s,t,e),Promise.all(i).then(function(){return t.targets!==void 0?Dv(s,t.targets,e):s})}var Cr=Math.pow(2,-24),Wo=Symbol("SKIP_GENERATION"),Qc={strategy:0,maxDepth:40,targetLeafSize:10,useSharedArrayBuffer:!1,setBoundingBox:!0,onProgress:null,indirect:!1,verbose:!0,range:null,[Wo]:!1};function fe(s,t,e){return e.min.x=t[s],e.min.y=t[s+1],e.min.z=t[s+2],e.max.x=t[s+3],e.max.y=t[s+4],e.max.z=t[s+5],e}function Xo(s){let t=-1,e=-1/0;for(let n=0;n<3;n++){let i=s[n+3]-s[n];i>e&&(e=i,t=n)}return t}function zu(s,t,e){for(let n=0;n<3;n++){let i=t[s+2*n],r=t[s+2*n+1],o=i-r,a=i+r;o<e[n]&&(e[n]=o),a>e[n+3]&&(e[n+3]=a)}}function tl(s){let t=s[3]-s[0],e=s[4]-s[1],n=s[5]-s[2];return 2*(t*e+e*n+n*t)}function $t(s,t){return t[s+15]===65535}function re(s,t){return t[s+6]}function ce(s,t){return t[s+14]}function ne(s){return s+8}function ie(s,t){let e=t[s+6];return s+e*8}function Pr(s,t){return t[s+7]}function el(s,t,e,n,i){let r=1/0,o=1/0,a=1/0,c=-1/0,l=-1/0,h=-1/0,f=1/0,u=1/0,d=1/0,g=-1/0,v=-1/0,m=-1/0,p=s.offset||0;for(let x=(t-p)*6,M=(t+e-p)*6;x<M;x+=6){let y=s[x+0],S=s[x+1],T=y-S,_=y+S;T<r&&(r=T),_>c&&(c=_),y<f&&(f=y),y>g&&(g=y);let b=s[x+2],I=s[x+3],E=b-I,L=b+I;E<o&&(o=E),L>l&&(l=L),b<u&&(u=b),b>v&&(v=b);let C=s[x+4],U=s[x+5],N=C-U,B=C+U;N<a&&(a=N),B>h&&(h=B),C<d&&(d=C),C>m&&(m=C)}n[0]=r,n[1]=o,n[2]=a,n[3]=c,n[4]=l,n[5]=h,i[0]=f,i[1]=u,i[2]=d,i[3]=g,i[4]=v,i[5]=m}var ui=8,Vu=8,ku=new Int32Array(ui),hi=new Float32Array(ui*6),Ir=new Float32Array(ui*6),Kn=new Float32Array(6),nl=new Float32Array(6),Qi=new Int32Array(Vu),Vp=new Float32Array(Vu*6);function Gv(s,t,e,n){for(let i=0;i<3;i++){let r=t[s+2*i],o=t[s+2*i+1],a=r-o,c=r+o;a<e[n+i]&&(e[n+i]=a),c>e[n+i+3]&&(e[n+i+3]=c)}}function Gp(s,t){let e=s[t+3]-s[t],n=s[t+4]-s[t+1],i=s[t+5]-s[t+2];return 2*(e*n+n*i+i*e)}function Hp(s,t,e,n,i,r){let o=-1,a=0;if(r===0)o=Xo(t),o!==-1&&(a=(t[o]+t[o+3])/2);else if(r===1)o=Xo(s),o!==-1&&(a=Hv(e,n,i,o));else if(r===2){let c=tl(s),l=1.25*i,h=e.offset||0,f=(n-h)*6,u=(n+i-h)*6;for(let d=0;d<3;d++){let g=t[d],p=(t[d+3]-g)/ui;if(i<Vu){for(let x=0;x<i;x++){let M=f+x*6,y=e[M+2*d],S=x;for(;S>0&&e[Qi[S-1]+2*d]>y;)Qi[S]=Qi[S-1],S--;Qi[S]=M}for(let x=0;x<3;x++)Kn[x]=1/0,Kn[x+3]=-1/0,nl[x]=1/0,nl[x+3]=-1/0;for(let x=i-1;x>=0;x--)zu(Qi[x],e,nl),Vp.set(nl,x*6);for(let x=0;x<i-1;x++){zu(Qi[x],e,Kn);let M=e[Qi[x+1]+2*d];if(e[Qi[x]+2*d]===M)continue;let y=x+1,S=i-y,T=tl(Kn)/c,_=Gp(Vp,y*6)/c,b=1+1.25*(T*y+_*S);b<l&&(o=d,l=b,a=M)}}else{for(let y=0;y<ui;y++){ku[y]=0;for(let S=0;S<3;S++)hi[y*6+S]=1/0,hi[y*6+S+3]=-1/0}for(let y=f;y<u;y+=6){let _=~~((e[y+2*d]-g)/p);_>=ui&&(_=ui-1),ku[_]++,Gv(y,e,hi,_*6)}let x=(ui-1)*6;for(let y=0;y<6;y++)Ir[x+y]=hi[x+y];for(let y=ui-2;y>=0;y--){let S=y*6,T=S+6;for(let _=0;_<3;_++)Ir[S+_]=Math.min(hi[S+_],Ir[T+_]),Ir[S+_+3]=Math.max(hi[S+_+3],Ir[T+_+3])}let M=0;for(let y=0;y<ui-1;y++){let S=y*6,T=ku[y];if(T!==0)for(let L=0;L<3;L++)M===0?(Kn[L]=hi[S+L],Kn[L+3]=hi[S+L+3]):(Kn[L]=Math.min(Kn[L],hi[S+L]),Kn[L+3]=Math.max(Kn[L+3],hi[S+L+3]));M+=T;let _=0,b=0;M!==0&&(_=tl(Kn)/c);let I=i-M;I!==0&&(b=Gp(Ir,S+6)/c);let E=1+1.25*(_*M+b*I);E<l&&(o=d,l=E,a=g+p+y*p)}}}}else console.warn(`BVH: Invalid build strategy value ${r} used.`);return{axis:o,pos:a}}function Hv(s,t,e,n){let i=0,r=s.offset;for(let o=t,a=t+e;o<a;o++)i+=s[(o-r)*6+n*2];return i/e}function Wp(s,t,e,n,i,r){let o=n,a=n+i-1,c=r.pos,l=r.axis*2,h=e.offset||0;for(;;){for(;o<=a&&e[(o-h)*6+l]<c;)o++;for(;o<=a&&e[(a-h)*6+l]>=c;)a--;if(o<a){for(let f=0;f<t;f++){let u=s[o*t+f];s[o*t+f]=s[a*t+f],s[a*t+f]=u}for(let f=0;f<6;f++){let u=o-h,d=a-h,g=e[u*6+f];e[u*6+f]=e[d*6+f],e[d*6+f]=g}o++,a--}else return o}}var Wv=Math.pow(2,32),Lr=new Float32Array(6),il=new Float32Array(6);function Xv(s,t,e,n,i,r){let{maxDepth:o,verbose:a,targetLeafSize:c,_strictLeafSize:l=1/0,strategy:h,onProgress:f,useSharedArrayBuffer:u=!1}=i,d=s.primitiveBuffer,g=s.primitiveBufferStride,v=u?SharedArrayBuffer:ArrayBuffer,m=new v(32*Math.max(1,2*Math.ceil(n)-1)),p=new Float32Array(m),x=new Uint32Array(m),M=new Uint16Array(m),y=0,S=!1;return el(t,e,n,Lr,il),b(e,n,0),m.slice(0,y*32);function T(I){f&&f((I-r.offset)/r.count)}function _(I,E,L){let C=I*2;x[I+6]=E,M[C+14]=L,M[C+15]=65535,T(E+L)}function b(I,E,L){let C=y++,U=C*8;p.set(Lr,U),!S&&L>=o&&(S=!0,a&&console.warn(`BVH: Max depth of ${o} reached when generating BVH. Consider increasing maxDepth.`));let N=E>l;if(E<=c&&!N||L>=o){_(U,I,E);return}let B=Hp(Lr,il,t,I,E,h),G=B.axis===-1?-1:Wp(d,g,t,I,E,B);if(B.axis===-1||G===I||G===I+E){if(!N){_(U,I,E);return}B.axis=Math.max(0,Xo(Lr)),G=I+Math.max(1,Math.floor(E/2))}x[U+7]=B.axis;let H=G-I;el(t,I,H,Lr,il),b(I,H,L+1);let tt=y-C;if(tt>Wv)throw new Error("MeshBVH: Cannot store relative child node offset greater than 32 bits.");x[U+6]=tt;let X=E-H;el(t,G,X,Lr,il),b(G,X,L+1)}}function Xp(s,t){let e=s.getRootRanges(t.range),n=e[0],i=e[e.length-1],r={offset:n.offset,count:i.offset+i.count-n.offset},o=new Float32Array(6*r.count);o.offset=r.offset,s.computePrimitiveBounds(r.offset,r.count,o),s._roots=e.map(a=>Xv(s,o,a.offset,a.count,t,r))}var ts=class{constructor(t){this._getNewPrimitive=t,this._primitives=[]}getPrimitive(){let t=this._primitives;return t.length===0?this._getNewPrimitive():t.pop()}releasePrimitive(t){this._primitives.push(t)}};var Gu=class{constructor(){this.float32Array=null,this.uint16Array=null,this.uint32Array=null;let t=[],e=null;this.setBuffer=n=>{e&&t.push(e),e=n,this.float32Array=new Float32Array(n),this.uint16Array=new Uint16Array(n),this.uint32Array=new Uint32Array(n)},this.clearBuffer=()=>{e=null,this.float32Array=null,this.uint16Array=null,this.uint32Array=null,t.length!==0&&this.setBuffer(t.pop())}}},Xt=new Gu;var es,Dr,Nr=[],sl=new ts(()=>new Jt);function qp(s,t,e,n,i,r){es=sl.getPrimitive(),Dr=sl.getPrimitive(),Nr.push(es,Dr),Xt.setBuffer(s._roots[t]);let o=Hu(0,s.geometry,e,n,i,r);Xt.clearBuffer(),sl.releasePrimitive(es),sl.releasePrimitive(Dr),Nr.pop(),Nr.pop();let a=Nr.length;return a>0&&(Dr=Nr[a-1],es=Nr[a-2]),o}function Hu(s,t,e,n,i=null,r=0,o=0){let{float32Array:a,uint16Array:c,uint32Array:l}=Xt,h=s*2;if($t(h,c)){let u=re(s,l),d=ce(h,c);return fe(s,a,es),n(u,d,!1,o,r+s/8,es)}else{let E=function(C){let{uint16Array:U,uint32Array:N}=Xt,B=C*2;for(;!$t(B,U);)C=ne(C),B=C*2;return re(C,N)},L=function(C){let{uint16Array:U,uint32Array:N}=Xt,B=C*2;for(;!$t(B,U);)C=ie(C,N),B=C*2;return re(C,N)+ce(B,U)},u=ne(s),d=ie(s,l),g=u,v=d,m,p,x,M;if(i&&(x=es,M=Dr,fe(g,a,x),fe(v,a,M),m=i(x),p=i(M),p<m)){g=d,v=u;let C=m;m=p,p=C,x=M}x||(x=es,fe(g,a,x));let y=$t(g*2,c),S=e(x,y,m,o+1,r+g/8),T;if(S===2){let C=E(g),N=L(g)-C;T=n(C,N,!0,o+1,r+g/8,x)}else T=S&&Hu(g,t,e,n,i,r,o+1);if(T)return!0;M=Dr,fe(v,a,M);let _=$t(v*2,c),b=e(M,_,p,o+1,r+v/8),I;if(b===2){let C=E(v),N=L(v)-C;I=n(C,N,!0,o+1,r+v/8,M)}else I=b&&Hu(v,t,e,n,i,r,o+1);return!!I}}var qo=new Xt.constructor,rl=new Xt.constructor,ns=new ts(()=>new Jt),Ur=new Jt,Fr=new Jt,Xu=new Jt,qu=new Jt,Yu=!1;function Yp(s,t,e,n){if(Yu)throw new Error("MeshBVH: Recursive calls to bvhcast not supported.");Yu=!0;let i=s._roots,r=t._roots,o,a=0,c=0,l=new _t().copy(e).invert();for(let h=0,f=i.length;h<f;h++){qo.setBuffer(i[h]),c=0;let u=ns.getPrimitive();fe(0,qo.float32Array,u),u.applyMatrix4(l);for(let d=0,g=r.length;d<g&&(rl.setBuffer(r[d]),o=Zn(0,0,e,l,n,a,c,0,0,u),rl.clearBuffer(),c+=r[d].byteLength/32,!o);d++);if(ns.releasePrimitive(u),qo.clearBuffer(),a+=i[h].byteLength/32,o)break}return Yu=!1,o}function Zn(s,t,e,n,i,r=0,o=0,a=0,c=0,l=null,h=!1){let f,u;h?(f=rl,u=qo):(f=qo,u=rl);let d=f.float32Array,g=f.uint32Array,v=f.uint16Array,m=u.float32Array,p=u.uint32Array,x=u.uint16Array,M=s*2,y=t*2,S=$t(M,v),T=$t(y,x),_=!1;if(T&&S)h?_=i(re(t,p),ce(t*2,x),re(s,g),ce(s*2,v),c,o+t/8,a,r+s/8):_=i(re(s,g),ce(s*2,v),re(t,p),ce(t*2,x),a,r+s/8,c,o+t/8);else if(T){let b=ns.getPrimitive();fe(t,m,b),b.applyMatrix4(e);let I=ne(s),E=ie(s,g);fe(I,d,Ur),fe(E,d,Fr);let L=b.intersectsBox(Ur),C=b.intersectsBox(Fr);_=L&&Zn(t,I,n,e,i,o,r,c,a+1,b,!h)||C&&Zn(t,E,n,e,i,o,r,c,a+1,b,!h),ns.releasePrimitive(b)}else{let b=ne(t),I=ie(t,p);fe(b,m,Xu),fe(I,m,qu);let E=l.intersectsBox(Xu),L=l.intersectsBox(qu);if(E&&L)_=Zn(s,b,e,n,i,r,o,a,c+1,l,h)||Zn(s,I,e,n,i,r,o,a,c+1,l,h);else if(E)if(S)_=Zn(s,b,e,n,i,r,o,a,c+1,l,h);else{let C=ns.getPrimitive();C.copy(Xu).applyMatrix4(e);let U=ne(s),N=ie(s,g);fe(U,d,Ur),fe(N,d,Fr);let B=C.intersectsBox(Ur),G=C.intersectsBox(Fr);_=B&&Zn(b,U,n,e,i,o,r,c,a+1,C,!h)||G&&Zn(b,N,n,e,i,o,r,c,a+1,C,!h),ns.releasePrimitive(C)}else if(L)if(S)_=Zn(s,I,e,n,i,r,o,a,c+1,l,h);else{let C=ns.getPrimitive();C.copy(qu).applyMatrix4(e);let U=ne(s),N=ie(s,g);fe(U,d,Ur),fe(N,d,Fr);let B=C.intersectsBox(Ur),G=C.intersectsBox(Fr);_=B&&Zn(I,U,n,e,i,o,r,c,a+1,C,!h)||G&&Zn(I,N,n,e,i,o,r,c,a+1,C,!h),ns.releasePrimitive(C)}}return _}var ol=new class{constructor(){let s=null,t=null,e=null,n=!1;this.root=null,this.buffer=null,this.uint32Array=null,this.uint16Array=null,this.setBVH=(r,o)=>{if(n)throw new Error("BVHTraversalHelper: cannot call setBVH during an active traversal.");this.root=o,this.buffer=s=r._roots[o],this.uint16Array=e=new Uint16Array(s),this.uint32Array=t=new Uint32Array(s)},this.reset=()=>{this.root=null,this.buffer=s=null,this.uint16Array=e=null,this.uint32Array=t=null},this.getRangeStart=r=>{let o=r*2;for(;!$t(o,e);)r=ne(r),o=r*2;return re(r,t)},this.getRangeEnd=r=>{let o=r*2;for(;!$t(o,e);)r=ie(r,t),o=r*2;return re(r,t)+ce(o,e)};let i=(r,o,a)=>{let c=o*2,l=$t(c,e);if(!r(a,l,o)&&!l){let f=ne(o),u=ie(o,t);i(r,f,a+1),i(r,u,a+1)}};this.traverseBuffer=r=>{if(n)throw new Error("BVHTraversalHelper: cannot start a traversal during an active traversal.");n=!0;try{i(r,0,0)}finally{n=!1}},this.traverse=r=>{this.traverseBuffer((o,a,c)=>{if(a){let l=c*2,h=t[c+6],f=e[l+14];return r(o,a,new Float32Array(s,c*4,6),h,f)}else{let l=Pr(c,t);return r(o,a,new Float32Array(s,c*4,6),l)}})}}};var Kp=new Jt,Or=new Float32Array(6),al=class{constructor(){this._roots=null,this.primitiveBuffer=null,this.primitiveBufferStride=null}init(t){t={...Qc,...t},"maxLeafSize"in t&&(console.warn('BVH: "maxLeafSize" option has been deprecated. Use "targetLeafSize", instead.'),t={...t,targetLeafSize:t.maxLeafSize}),Xp(this,t)}getRootRanges(){throw new Error("BVH: getRootRanges() not implemented")}writePrimitiveBounds(){throw new Error("BVH: writePrimitiveBounds() not implemented")}writePrimitiveRangeBounds(t,e,n,i){let r=1/0,o=1/0,a=1/0,c=-1/0,l=-1/0,h=-1/0;for(let f=t,u=t+e;f<u;f++){this.writePrimitiveBounds(f,Or,0);let[d,g,v,m,p,x]=Or;d<r&&(r=d),m>c&&(c=m),g<o&&(o=g),p>l&&(l=p),v<a&&(a=v),x>h&&(h=x)}return n[i+0]=r,n[i+1]=o,n[i+2]=a,n[i+3]=c,n[i+4]=l,n[i+5]=h,n}computePrimitiveBounds(t,e,n){let i=n.offset||0;for(let r=t,o=t+e;r<o;r++){this.writePrimitiveBounds(r,Or,0);let[a,c,l,h,f,u]=Or,d=(a+h)/2,g=(c+f)/2,v=(l+u)/2,m=(h-a)/2,p=(f-c)/2,x=(u-l)/2,M=(r-i)*6;n[M+0]=d,n[M+1]=m+(Math.abs(d)+m)*Cr,n[M+2]=g,n[M+3]=p+(Math.abs(g)+p)*Cr,n[M+4]=v,n[M+5]=x+(Math.abs(v)+x)*Cr}return n}shiftPrimitiveOffsets(t){let e=this._indirectBuffer;if(e)for(let n=0,i=e.length;n<i;n++)e[n]+=t;else{let n=this._roots;for(let i=0;i<n.length;i++){let r=n[i],o=new Uint32Array(r),a=new Uint16Array(r),c=r.byteLength/32;for(let l=0;l<c;l++){let h=8*l,f=2*h;$t(f,a)&&(o[h+6]+=t)}}}}traverse(t,e=0){ol.setBVH(this,e),ol.traverse(t),ol.reset()}refit(){let t=this._roots;for(let e=0,n=t.length;e<n;e++){let i=t[e],r=new Uint32Array(i),o=new Uint16Array(i),a=new Float32Array(i),c=i.byteLength/32;for(let l=c-1;l>=0;l--){let h=l*8,f=h*2;if($t(f,o)){let d=re(h,r),g=ce(f,o);this.writePrimitiveRangeBounds(d,g,Or,0),a.set(Or,h)}else{let d=ne(h),g=ie(h,r);for(let v=0;v<3;v++){let m=a[d+v],p=a[d+v+3],x=a[g+v],M=a[g+v+3];a[h+v]=m<x?m:x,a[h+v+3]=p>M?p:M}}}}}getBoundingBox(t){return t.makeEmpty(),this._roots.forEach(n=>{fe(0,new Float32Array(n),Kp),t.union(Kp)}),t}shapecast(t){let{boundsTraverseOrder:e,intersectsBounds:n,intersectsRange:i,intersectsPrimitive:r,scratchPrimitive:o,iterate:a}=t;if(i&&r){let f=i;i=(u,d,g,v,m)=>f(u,d,g,v,m)?!0:a(u,d,this,r,g,v,o)}else i||(r?i=(f,u,d,g)=>a(f,u,this,r,d,g,o):i=(f,u,d)=>d);let c=!1,l=0,h=this._roots;for(let f=0,u=h.length;f<u;f++){let d=h[f];if(c=qp(this,f,n,i,e,l),c)break;l+=d.byteLength/32}return c}bvhcast(t,e,n){let{intersectsRanges:i}=n;return Yp(this,t,e,i)}};function Zp(){return typeof SharedArrayBuffer<"u"}function Ku(s){return s.index?s.index.count:s.attributes.position.count}function is(s){return Ku(s)/3}function Yv(s,t=ArrayBuffer){return s>65535?new Uint32Array(new t(4*s)):new Uint16Array(new t(2*s))}function Jp(s,t){if(!s.index){let e=s.attributes.position.count,n=t.useSharedArrayBuffer?SharedArrayBuffer:ArrayBuffer,i=Yv(e,n);s.setIndex(new Te(i,1));for(let r=0;r<e;r++)i[r]=r}}function Kv(s,t,e){let n=Ku(s)/e,i=t||s.drawRange,r=i.start/e,o=(i.start+i.count)/e,a=Math.max(0,r),c=Math.min(n,o)-a;return{offset:Math.floor(a),count:Math.floor(c)}}function Zv(s,t){return s.groups.map(e=>({offset:e.start/t,count:e.count/t}))}function Zu(s,t,e){let n=Kv(s,t,e),i=Zv(s,e);if(!i.length)return[n];let r=[],o=n.offset,a=n.offset+n.count,c=Ku(s)/e,l=[];for(let u of i){let{offset:d,count:g}=u,v=d,m=isFinite(g)?g:c-d,p=d+m;v<a&&p>o&&(l.push({pos:Math.max(o,v),isStart:!0}),l.push({pos:Math.min(a,p),isStart:!1}))}l.sort((u,d)=>u.pos!==d.pos?u.pos-d.pos:u.type==="end"?-1:1);let h=0,f=null;for(let u of l){let d=u.pos;h!==0&&d!==f&&r.push({offset:f,count:d-f}),h+=u.isStart?1:-1,f=d}return r}function Jv(s,t){let e=s[s.length-1],n=e.offset+e.count>2**16,i=s.reduce((l,h)=>l+h.count,0),r=n?4:2,o=t?new SharedArrayBuffer(i*r):new ArrayBuffer(i*r),a=n?new Uint32Array(o):new Uint16Array(o),c=0;for(let l=0;l<s.length;l++){let{offset:h,count:f}=s[l];for(let u=0;u<f;u++)a[c+u]=h+u;c+=f}return a}var cl=class extends al{get indirect(){return!!this._indirectBuffer}get primitiveStride(){return null}get primitiveBufferStride(){return this.indirect?1:this.primitiveStride}set primitiveBufferStride(t){}get primitiveBuffer(){return this.indirect?this._indirectBuffer:this.geometry.index.array}set primitiveBuffer(t){}constructor(t,e={}){if(t.isBufferGeometry){if(t.index&&t.index.isInterleavedBufferAttribute)throw new Error("BVH: InterleavedBufferAttribute is not supported for the index attribute.")}else throw new Error("BVH: Only BufferGeometries are supported.");if(e.useSharedArrayBuffer&&!Zp())throw new Error("BVH: SharedArrayBuffer is not available.");super(),this.geometry=t,this.resolvePrimitiveIndex=e.indirect?n=>this._indirectBuffer[n]:n=>n,this.primitiveBuffer=null,this.primitiveBufferStride=null,this._indirectBuffer=null,e={...Qc,...e},e[Wo]||this.init(e)}init(t){let{geometry:e,primitiveStride:n}=this;if(t.indirect){let i=Zu(e,t.range,n),r=Jv(i,t.useSharedArrayBuffer);this._indirectBuffer=r}else Jp(e,t);super.init(t),!e.boundingBox&&t.setBoundingBox&&(e.boundingBox=this.getBoundingBox(new Jt))}getRootRanges(t){return this.indirect?[{offset:0,count:this._indirectBuffer.length}]:Zu(this.geometry,t,this.primitiveStride)}raycastObject3D(){throw new Error("BVH: raycastObject3D() not implemented")}};var Rn=class{constructor(){this.min=1/0,this.max=-1/0}setFromPointsField(t,e){let n=1/0,i=-1/0;for(let r=0,o=t.length;r<o;r++){let c=t[r][e];n=c<n?c:n,i=c>i?c:i}this.min=n,this.max=i}setFromPoints(t,e){let n=1/0,i=-1/0;for(let r=0,o=e.length;r<o;r++){let a=e[r],c=t.dot(a);n=c<n?c:n,i=c>i?c:i}this.min=n,this.max=i}isSeparated(t){return this.min>t.max||t.min>this.max}};Rn.prototype.setFromBox=(function(){let s=new R;return function(e,n){let i=n.min,r=n.max,o=1/0,a=-1/0;for(let c=0;c<=1;c++)for(let l=0;l<=1;l++)for(let h=0;h<=1;h++){s.x=i.x*c+r.x*(1-c),s.y=i.y*l+r.y*(1-l),s.z=i.z*h+r.z*(1-h);let f=e.dot(s);o=Math.min(f,o),a=Math.max(f,a)}this.min=o,this.max=a}})();var $v=(function(){let s=new R,t=new R,e=new R;return function(i,r,o){let a=i.start,c=s,l=r.start,h=t;e.subVectors(a,l),s.subVectors(i.end,i.start),t.subVectors(r.end,r.start);let f=e.dot(h),u=h.dot(c),d=h.dot(h),g=e.dot(c),m=c.dot(c)*d-u*u,p,x;m!==0?p=(f*u-g*d)/m:p=0,x=(f+p*u)/d,o.x=p,o.y=x}})(),Yo=(function(){let s=new At,t=new R,e=new R;return function(i,r,o,a){$v(i,r,s);let c=s.x,l=s.y;if(c>=0&&c<=1&&l>=0&&l<=1){i.at(c,o),r.at(l,a);return}else if(c>=0&&c<=1){l<0?r.at(0,a):r.at(1,a),i.closestPointToPoint(a,!0,o);return}else if(l>=0&&l<=1){c<0?i.at(0,o):i.at(1,o),r.closestPointToPoint(o,!0,a);return}else{let h;c<0?h=i.start:h=i.end;let f;l<0?f=r.start:f=r.end;let u=t,d=e;if(i.closestPointToPoint(f,!0,t),r.closestPointToPoint(h,!0,e),u.distanceToSquared(f)<=d.distanceToSquared(h)){o.copy(u),a.copy(f);return}else{o.copy(h),a.copy(d);return}}}})(),$p=(function(){let s=new R,t=new R,e=new $e,n=new Qe;return function(r,o){let{radius:a,center:c}=r,{a:l,b:h,c:f}=o;if(n.start=l,n.end=h,n.closestPointToPoint(c,!0,s).distanceTo(c)<=a||(n.start=l,n.end=f,n.closestPointToPoint(c,!0,s).distanceTo(c)<=a)||(n.start=h,n.end=f,n.closestPointToPoint(c,!0,s).distanceTo(c)<=a))return!0;let v=o.getPlane(e);if(Math.abs(v.distanceToPoint(c))<=a){let p=v.projectPoint(c,t);if(o.containsPoint(p))return!0}return!1}})();var jv=["x","y","z"],Fi=1e-15,jp=Fi*Fi;function Bn(s){return Math.abs(s)<Fi}var tn=class extends on{constructor(...t){super(...t),this.isExtendedTriangle=!0,this.satAxes=new Array(4).fill().map(()=>new R),this.satBounds=new Array(4).fill().map(()=>new Rn),this.points=[this.a,this.b,this.c],this.plane=new $e,this.isDegenerateIntoSegment=!1,this.isDegenerateIntoPoint=!1,this.degenerateSegment=new Qe,this.needsUpdate=!0}intersectsSphere(t){return $p(t,this)}update(){let t=this.a,e=this.b,n=this.c,i=this.points,r=this.satAxes,o=this.satBounds,a=r[0],c=o[0];this.getNormal(a),c.setFromPoints(a,i);let l=r[1],h=o[1];l.subVectors(t,e),h.setFromPoints(l,i);let f=r[2],u=o[2];f.subVectors(e,n),u.setFromPoints(f,i);let d=r[3],g=o[3];d.subVectors(n,t),g.setFromPoints(d,i);let v=l.length(),m=f.length(),p=d.length();this.isDegenerateIntoPoint=!1,this.isDegenerateIntoSegment=!1,v<Fi?m<Fi||p<Fi?this.isDegenerateIntoPoint=!0:(this.isDegenerateIntoSegment=!0,this.degenerateSegment.start.copy(t),this.degenerateSegment.end.copy(n)):m<Fi?p<Fi?this.isDegenerateIntoPoint=!0:(this.isDegenerateIntoSegment=!0,this.degenerateSegment.start.copy(e),this.degenerateSegment.end.copy(t)):p<Fi&&(this.isDegenerateIntoSegment=!0,this.degenerateSegment.start.copy(n),this.degenerateSegment.end.copy(e)),this.plane.setFromNormalAndCoplanarPoint(a,t),this.needsUpdate=!1}};tn.prototype.closestPointToSegment=(function(){let s=new R,t=new R,e=new Qe;return function(i,r=null,o=null){this.needsUpdate&&this.update();let{start:a,end:c}=i,l=this.points,h,f=1/0,u=this.plane.distanceToPoint(a),d=this.plane.distanceToPoint(c);if(u*d<0&&this.plane.intersectLine(i,s)!==null&&this.containsPoint(s))return r&&r.copy(s),o&&o.copy(s),0;for(let g=0;g<3;g++){let v=(g+1)%3;e.start.copy(l[g]),e.end.copy(l[v]),Yo(e,i,s,t),h=s.distanceToSquared(t),h<f&&(f=h,r&&r.copy(s),o&&o.copy(t))}return this.closestPointToPoint(a,s),h=a.distanceToSquared(s),h<f&&(f=h,r&&r.copy(s),o&&o.copy(a)),this.closestPointToPoint(c,s),h=c.distanceToSquared(s),h<f&&(f=h,r&&r.copy(s),o&&o.copy(c)),Math.sqrt(f)}})();tn.prototype.intersectsTriangle=(function(){let s=new tn,t=new Rn,e=new Rn,n=new R,i=new R,r=new R,o=new R,a=new Qe,c=new Qe,l=new R,h=new At,f=new At;function u(M,y,S,T){let _=n;!M.isDegenerateIntoPoint&&!M.isDegenerateIntoSegment?_.copy(M.plane.normal):_.copy(y.plane.normal);let b=M.satBounds,I=M.satAxes;for(let C=1;C<4;C++){let U=b[C],N=I[C];if(t.setFromPoints(N,y.points),U.isSeparated(t)||(o.copy(_).cross(N),t.setFromPoints(o,M.points),e.setFromPoints(o,y.points),t.isSeparated(e)))return!1}let E=y.satBounds,L=y.satAxes;for(let C=1;C<4;C++){let U=E[C],N=L[C];if(t.setFromPoints(N,M.points),U.isSeparated(t)||(o.crossVectors(_,N),t.setFromPoints(o,M.points),e.setFromPoints(o,y.points),t.isSeparated(e)))return!1}return S&&(T||console.warn("ExtendedTriangle.intersectsTriangle: Triangles are coplanar which does not support an output edge. Setting edge to 0, 0, 0."),S.start.set(0,0,0),S.end.set(0,0,0)),!0}function d(M,y,S,T,_,b,I,E,L,C,U){let N=I/(I-E);C.x=T+(_-T)*N,U.start.subVectors(y,M).multiplyScalar(N).add(M),N=I/(I-L),C.y=T+(b-T)*N,U.end.subVectors(S,M).multiplyScalar(N).add(M)}function g(M,y,S,T,_,b,I,E,L,C,U){if(_>0)d(M.c,M.a,M.b,T,y,S,L,I,E,C,U);else if(b>0)d(M.b,M.a,M.c,S,y,T,E,I,L,C,U);else if(E*L>0||I!=0)d(M.a,M.b,M.c,y,S,T,I,E,L,C,U);else if(E!=0)d(M.b,M.a,M.c,S,y,T,E,I,L,C,U);else if(L!=0)d(M.c,M.a,M.b,T,y,S,L,I,E,C,U);else return!0;return!1}function v(M,y,S,T){let _=y.degenerateSegment,b=M.plane.distanceToPoint(_.start),I=M.plane.distanceToPoint(_.end);return Bn(b)?Bn(I)?u(M,y,S,T):(S&&(S.start.copy(_.start),S.end.copy(_.start)),M.containsPoint(_.start)):Bn(I)?(S&&(S.start.copy(_.end),S.end.copy(_.end)),M.containsPoint(_.end)):M.plane.intersectLine(_,n)!=null?(S&&(S.start.copy(n),S.end.copy(n)),M.containsPoint(n)):!1}function m(M,y,S){let T=y.a;return Bn(M.plane.distanceToPoint(T))&&M.containsPoint(T)?(S&&(S.start.copy(T),S.end.copy(T)),!0):!1}function p(M,y,S){let T=M.degenerateSegment,_=y.a;return T.closestPointToPoint(_,!0,n),_.distanceToSquared(n)<jp?(S&&(S.start.copy(_),S.end.copy(_)),!0):!1}function x(M,y,S,T){if(M.isDegenerateIntoSegment)if(y.isDegenerateIntoSegment){let _=M.degenerateSegment,b=y.degenerateSegment,I=i,E=r;_.delta(I),b.delta(E);let L=n.subVectors(b.start,_.start),C=I.x*E.y-I.y*E.x;if(Bn(C))return!1;let U=(L.x*E.y-L.y*E.x)/C,N=-(I.x*L.y-I.y*L.x)/C;if(U<0||U>1||N<0||N>1)return!1;let B=_.start.z+I.z*U,G=b.start.z+E.z*N;return Bn(B-G)?(S&&(S.start.copy(_.start).addScaledVector(I,U),S.end.copy(_.start).addScaledVector(I,U)),!0):!1}else return y.isDegenerateIntoPoint?p(M,y,S):v(y,M,S,T);else{if(M.isDegenerateIntoPoint)return y.isDegenerateIntoPoint?y.a.distanceToSquared(M.a)<jp?(S&&(S.start.copy(M.a),S.end.copy(M.a)),!0):!1:y.isDegenerateIntoSegment?p(y,M,S):m(y,M,S);if(y.isDegenerateIntoPoint)return m(M,y,S);if(y.isDegenerateIntoSegment)return v(M,y,S,T)}}return function(y,S=null,T=!1){this.needsUpdate&&this.update(),y.isExtendedTriangle?y.needsUpdate&&y.update():(s.copy(y),s.update(),y=s);let _=x(this,y,S,T);if(_!==void 0)return _;let b=this.plane,I=y.plane,E=I.distanceToPoint(this.a),L=I.distanceToPoint(this.b),C=I.distanceToPoint(this.c);Bn(E)&&(E=0),Bn(L)&&(L=0),Bn(C)&&(C=0);let U=E*L,N=E*C;if(U>0&&N>0)return!1;let B=b.distanceToPoint(y.a),G=b.distanceToPoint(y.b),H=b.distanceToPoint(y.c);Bn(B)&&(B=0),Bn(G)&&(G=0),Bn(H)&&(H=0);let tt=B*G,X=B*H;if(tt>0&&X>0)return!1;i.copy(b.normal),r.copy(I.normal);let j=i.cross(r),Q=0,yt=Math.abs(j.x),Ut=Math.abs(j.y);Ut>yt&&(yt=Ut,Q=1),Math.abs(j.z)>yt&&(Q=2);let lt=jv[Q],xt=this.a[lt],Ct=this.b[lt],dt=this.c[lt],Ot=y.a[lt],Ce=y.b[lt],It=y.c[lt];if(g(this,xt,Ct,dt,U,N,E,L,C,h,a))return u(this,y,S,T);if(g(y,Ot,Ce,It,tt,X,B,G,H,f,c))return u(this,y,S,T);if(h.y<h.x){let jt=h.y;h.y=h.x,h.x=jt,l.copy(a.start),a.start.copy(a.end),a.end.copy(l)}if(f.y<f.x){let jt=f.y;f.y=f.x,f.x=jt,l.copy(c.start),c.start.copy(c.end),c.end.copy(l)}return h.y<f.x||f.y<h.x?!1:(S&&(f.x>h.x?S.start.copy(c.start):S.start.copy(a.start),f.y<h.y?S.end.copy(c.end):S.end.copy(a.end)),!0)}})();tn.prototype.distanceToPoint=(function(){let s=new R;return function(e){return this.closestPointToPoint(e,s),e.distanceTo(s)}})();tn.prototype.distanceToTriangle=(function(){let s=new R,t=new R,e=["a","b","c"],n=new Qe,i=new Qe;return function(o,a=null,c=null){let l=a||c?n:null;if(this.intersectsTriangle(o,l,!0))return(a||c)&&(a&&l.getCenter(a),c&&l.getCenter(c)),0;let h=1/0;for(let f=0;f<3;f++){let u,d=e[f],g=o[d];this.closestPointToPoint(g,s),u=g.distanceToSquared(s),u<h&&(h=u,a&&a.copy(s),c&&c.copy(g));let v=this[d];o.closestPointToPoint(v,s),u=v.distanceToSquared(s),u<h&&(h=u,a&&a.copy(v),c&&c.copy(s))}for(let f=0;f<3;f++){let u=e[f],d=e[(f+1)%3];n.set(this[u],this[d]);for(let g=0;g<3;g++){let v=e[g],m=e[(g+1)%3];i.set(o[v],o[m]),Yo(n,i,s,t);let p=s.distanceToSquared(t);p<h&&(h=p,a&&a.copy(s),c&&c.copy(t))}}return Math.sqrt(h)}})();var Ie=class{constructor(t,e,n){this.isOrientedBox=!0,this.min=new R,this.max=new R,this.matrix=new _t,this.invMatrix=new _t,this.points=new Array(8).fill().map(()=>new R),this.satAxes=new Array(3).fill().map(()=>new R),this.satBounds=new Array(3).fill().map(()=>new Rn),this.alignedSatBounds=new Array(3).fill().map(()=>new Rn),this.needsUpdate=!1,t&&this.min.copy(t),e&&this.max.copy(e),n&&this.matrix.copy(n)}set(t,e,n){this.min.copy(t),this.max.copy(e),this.matrix.copy(n),this.needsUpdate=!0}copy(t){this.min.copy(t.min),this.max.copy(t.max),this.matrix.copy(t.matrix),this.needsUpdate=!0}};Ie.prototype.update=(function(){return function(){let t=this.matrix,e=this.min,n=this.max,i=this.points;for(let l=0;l<=1;l++)for(let h=0;h<=1;h++)for(let f=0;f<=1;f++){let u=1*l|2*h|4*f,d=i[u];d.x=l?n.x:e.x,d.y=h?n.y:e.y,d.z=f?n.z:e.z,d.applyMatrix4(t)}let r=this.satBounds,o=this.satAxes,a=i[0];for(let l=0;l<3;l++){let h=o[l],f=r[l],u=1<<l,d=i[u];h.subVectors(a,d),f.setFromPoints(h,i)}let c=this.alignedSatBounds;c[0].setFromPointsField(i,"x"),c[1].setFromPointsField(i,"y"),c[2].setFromPointsField(i,"z"),this.invMatrix.copy(this.matrix).invert(),this.needsUpdate=!1}})();Ie.prototype.intersectsBox=(function(){let s=new Rn;return function(e){this.needsUpdate&&this.update();let n=e.min,i=e.max,r=this.satBounds,o=this.satAxes,a=this.alignedSatBounds;if(s.min=n.x,s.max=i.x,a[0].isSeparated(s)||(s.min=n.y,s.max=i.y,a[1].isSeparated(s))||(s.min=n.z,s.max=i.z,a[2].isSeparated(s)))return!1;for(let c=0;c<3;c++){let l=o[c],h=r[c];if(s.setFromBox(l,e),h.isSeparated(s))return!1}return!0}})();Ie.prototype.intersectsTriangle=(function(){let s=new tn,t=new Array(3),e=new Rn,n=new Rn,i=new R;return function(o){this.needsUpdate&&this.update(),o.isExtendedTriangle?o.needsUpdate&&o.update():(s.copy(o),s.update(),o=s);let a=this.satBounds,c=this.satAxes;t[0]=o.a,t[1]=o.b,t[2]=o.c;for(let u=0;u<3;u++){let d=a[u],g=c[u];if(e.setFromPoints(g,t),d.isSeparated(e))return!1}let l=o.satBounds,h=o.satAxes,f=this.points;for(let u=0;u<3;u++){let d=l[u],g=h[u];if(e.setFromPoints(g,f),d.isSeparated(e))return!1}for(let u=0;u<3;u++){let d=c[u];for(let g=0;g<4;g++){let v=h[g];if(i.crossVectors(d,v),e.setFromPoints(i,t),n.setFromPoints(i,f),e.isSeparated(n))return!1}}return!0}})();Ie.prototype.closestPointToPoint=(function(){return function(t,e){return this.needsUpdate&&this.update(),e.copy(t).applyMatrix4(this.invMatrix).clamp(this.min,this.max).applyMatrix4(this.matrix),e}})();Ie.prototype.distanceToPoint=(function(){let s=new R;return function(e){return this.closestPointToPoint(e,s),e.distanceTo(s)}})();Ie.prototype.distanceToBox=(function(){let s=["x","y","z"],t=new Array(12).fill().map(()=>new Qe),e=new Array(12).fill().map(()=>new Qe),n=new R,i=new R;return function(o,a=0,c=null,l=null){if(this.needsUpdate&&this.update(),this.intersectsBox(o))return(c||l)&&(o.getCenter(i),this.closestPointToPoint(i,n),o.closestPointToPoint(n,i),c&&c.copy(n),l&&l.copy(i)),0;let h=a*a,f=o.min,u=o.max,d=this.points,g=1/0;for(let m=0;m<8;m++){let p=d[m];i.copy(p).clamp(f,u);let x=p.distanceToSquared(i);if(x<g&&(g=x,c&&c.copy(p),l&&l.copy(i),x<h))return Math.sqrt(x)}let v=0;for(let m=0;m<3;m++)for(let p=0;p<=1;p++)for(let x=0;x<=1;x++){let M=(m+1)%3,y=(m+2)%3,S=p<<M|x<<y,T=1<<m|p<<M|x<<y,_=d[S],b=d[T];t[v].set(_,b);let E=s[m],L=s[M],C=s[y],U=e[v],N=U.start,B=U.end;N[E]=f[E],N[L]=p?f[L]:u[L],N[C]=x?f[C]:u[C],B[E]=u[E],B[L]=p?f[L]:u[L],B[C]=x?f[C]:u[C],v++}for(let m=0;m<=1;m++)for(let p=0;p<=1;p++)for(let x=0;x<=1;x++){i.x=m?u.x:f.x,i.y=p?u.y:f.y,i.z=x?u.z:f.z,this.closestPointToPoint(i,n);let M=i.distanceToSquared(n);if(M<g&&(g=M,c&&c.copy(n),l&&l.copy(i),M<h))return Math.sqrt(M)}for(let m=0;m<12;m++){let p=t[m];for(let x=0;x<12;x++){let M=e[x];Yo(p,M,n,i);let y=n.distanceToSquared(i);if(y<g&&(g=y,c&&c.copy(n),l&&l.copy(i),y<h))return Math.sqrt(y)}}return Math.sqrt(g)}})();var Ju=class extends ts{constructor(){super(()=>new tn)}},mn=new Ju;var Ko=new R,$u=new R;function Qp(s,t,e={},n=0,i=1/0){let r=n*n,o=i*i,a=1/0,c=null;if(s.shapecast({boundsTraverseOrder:h=>(Ko.copy(t).clamp(h.min,h.max),Ko.distanceToSquared(t)),intersectsBounds:(h,f,u)=>u<a&&u<o,intersectsTriangle:(h,f)=>{h.closestPointToPoint(t,Ko);let u=t.distanceToSquared(Ko);return u<a&&($u.copy(Ko),a=u,c=f),u<r}}),a===1/0)return null;let l=Math.sqrt(a);return e.point?e.point.copy($u):e.point=$u.clone(),e.distance=l,e.faceIndex=c,e}var ll=parseInt("187")>=169,Qv=parseInt("187")<=161,Ns=new R,Ds=new R,Us=new R,hl=new At,ul=new At,fl=new At,tm=new R,em=new R,nm=new R,Zo=new R;function tM(s,t,e,n,i,r,o,a){let c;if(r===Ne?c=s.intersectTriangle(n,e,t,!0,i):c=s.intersectTriangle(t,e,n,r!==Pe,i),c===null)return null;let l=s.origin.distanceTo(i);return l<o||l>a?null:{distance:l,point:i.clone()}}function im(s,t,e,n,i,r,o,a,c,l,h){Ns.fromBufferAttribute(t,r),Ds.fromBufferAttribute(t,o),Us.fromBufferAttribute(t,a);let f=tM(s,Ns,Ds,Us,Zo,c,l,h);if(f){if(n){hl.fromBufferAttribute(n,r),ul.fromBufferAttribute(n,o),fl.fromBufferAttribute(n,a),f.uv=new At;let d=on.getInterpolation(Zo,Ns,Ds,Us,hl,ul,fl,f.uv);ll||(f.uv=d)}if(i){hl.fromBufferAttribute(i,r),ul.fromBufferAttribute(i,o),fl.fromBufferAttribute(i,a),f.uv1=new At;let d=on.getInterpolation(Zo,Ns,Ds,Us,hl,ul,fl,f.uv1);ll||(f.uv1=d),Qv&&(f.uv2=f.uv1)}if(e){tm.fromBufferAttribute(e,r),em.fromBufferAttribute(e,o),nm.fromBufferAttribute(e,a),f.normal=new R;let d=on.getInterpolation(Zo,Ns,Ds,Us,tm,em,nm,f.normal);f.normal.dot(s.direction)>0&&f.normal.multiplyScalar(-1),ll||(f.normal=d)}let u={a:r,b:o,c:a,normal:new R,materialIndex:0};if(on.getNormal(Ns,Ds,Us,u.normal),f.face=u,f.faceIndex=r,ll){let d=new R;on.getBarycoord(Zo,Ns,Ds,Us,d),f.barycoord=d}}return f}function sm(s){return s&&s.isMaterial?s.side:s}function Br(s,t,e,n,i,r,o){let a=n*3,c=a+0,l=a+1,h=a+2,{index:f,groups:u}=s;s.index&&(c=f.getX(c),l=f.getX(l),h=f.getX(h));let{position:d,normal:g,uv:v,uv1:m}=s.attributes;if(Array.isArray(t)){let p=n*3;for(let x=0,M=u.length;x<M;x++){let{start:y,count:S,materialIndex:T}=u[x];if(p>=y&&p<y+S){let _=sm(t[T]),b=im(e,d,g,v,m,c,l,h,_,r,o);if(b)if(b.faceIndex=n,b.face.materialIndex=T,i)i.push(b);else return b}}}else{let p=sm(t),x=im(e,d,g,v,m,c,l,h,p,r,o);if(x)if(x.faceIndex=n,x.face.materialIndex=0,i)i.push(x);else return x}return null}function de(s,t,e,n){let i=s.a,r=s.b,o=s.c,a=t,c=t+1,l=t+2;e&&(a=e.getX(a),c=e.getX(c),l=e.getX(l)),i.x=n.getX(a),i.y=n.getY(a),i.z=n.getZ(a),r.x=n.getX(c),r.y=n.getY(c),r.z=n.getZ(c),o.x=n.getX(l),o.y=n.getY(l),o.z=n.getZ(l)}function rm(s,t,e,n,i,r,o,a){let{geometry:c,_indirectBuffer:l}=s;for(let h=n,f=n+i;h<f;h++)Br(c,t,e,h,r,o,a)}function om(s,t,e,n,i,r,o){let{geometry:a,_indirectBuffer:c}=s,l=1/0,h=null;for(let f=n,u=n+i;f<u;f++){let d;d=Br(a,t,e,f,null,r,o),d&&d.distance<l&&(h=d,l=d.distance)}return h}function am(s,t,e,n,i,r,o){let{geometry:a}=e,{index:c}=a,l=a.attributes.position;for(let h=s,f=t+s;h<f;h++){let u;if(u=h,de(o,u*3,c,l),o.needsUpdate=!0,n(o,u,i,r))return!0}return!1}function cm(s,t=null){t&&Array.isArray(t)&&(t=new Set(t));let e=s.geometry,n=e.index?e.index.array:null,i=e.attributes.position,r,o,a,c,l=0,h=s._roots;for(let u=0,d=h.length;u<d;u++)r=h[u],o=new Uint32Array(r),a=new Uint16Array(r),c=new Float32Array(r),f(0,l),l+=r.byteLength;function f(u,d,g=!1){let v=u*2;if($t(v,a)){let m=re(u,o),p=ce(v,a),x=1/0,M=1/0,y=1/0,S=-1/0,T=-1/0,_=-1/0;for(let b=3*m,I=3*(m+p);b<I;b++){let E=n[b],L=i.getX(E),C=i.getY(E),U=i.getZ(E);L<x&&(x=L),L>S&&(S=L),C<M&&(M=C),C>T&&(T=C),U<y&&(y=U),U>_&&(_=U)}return c[u+0]!==x||c[u+1]!==M||c[u+2]!==y||c[u+3]!==S||c[u+4]!==T||c[u+5]!==_?(c[u+0]=x,c[u+1]=M,c[u+2]=y,c[u+3]=S,c[u+4]=T,c[u+5]=_,!0):!1}else{let m=ne(u),p=ie(u,o),x=g,M=!1,y=!1;if(t){if(!x){let E=m/8+d/32,L=p/8+d/32;M=t.has(E),y=t.has(L),x=!M&&!y}}else M=!0,y=!0;let S=x||M,T=x||y,_=!1;S&&(_=f(m,d,x));let b=!1;T&&(b=f(p,d,x));let I=_||b;if(I)for(let E=0;E<3;E++){let L=m+E,C=p+E,U=c[L],N=c[L+3],B=c[C],G=c[C+3];c[u+E]=U<B?U:B,c[u+E+3]=N>G?N:G}return I}}}function hn(s,t,e,n,i){let r,o,a,c,l,h,f=1/e.direction.x,u=1/e.direction.y,d=1/e.direction.z,g=e.origin.x,v=e.origin.y,m=e.origin.z,p=t[s],x=t[s+3],M=t[s+1],y=t[s+3+1],S=t[s+2],T=t[s+3+2];return f>=0?(r=(p-g)*f,o=(x-g)*f):(r=(x-g)*f,o=(p-g)*f),u>=0?(a=(M-v)*u,c=(y-v)*u):(a=(y-v)*u,c=(M-v)*u),r>c||a>o||((a>r||isNaN(r))&&(r=a),(c<o||isNaN(o))&&(o=c),d>=0?(l=(S-m)*d,h=(T-m)*d):(l=(T-m)*d,h=(S-m)*d),r>h||l>o)?!1:((l>r||r!==r)&&(r=l),(h<o||o!==o)&&(o=h),r<=i&&o>=n)}function lm(s,t,e,n,i,r,o,a){let{geometry:c,_indirectBuffer:l}=s;for(let h=n,f=n+i;h<f;h++){let u=l?l[h]:h;Br(c,t,e,u,r,o,a)}}function hm(s,t,e,n,i,r,o){let{geometry:a,_indirectBuffer:c}=s,l=1/0,h=null;for(let f=n,u=n+i;f<u;f++){let d;d=Br(a,t,e,c?c[f]:f,null,r,o),d&&d.distance<l&&(h=d,l=d.distance)}return h}function um(s,t,e,n,i,r,o){let{geometry:a}=e,{index:c}=a,l=a.attributes.position;for(let h=s,f=t+s;h<f;h++){let u;if(u=e.resolveTriangleIndex(h),de(o,u*3,c,l),o.needsUpdate=!0,n(o,u,i,r))return!0}return!1}function fm(s,t,e,n,i,r,o){Xt.setBuffer(s._roots[t]),hn(0,Xt.float32Array,n,r,o)&&ju(0,s,e,n,i,r,o),Xt.clearBuffer()}function ju(s,t,e,n,i,r,o){let{float32Array:a,uint16Array:c,uint32Array:l}=Xt,h=s*2;if($t(h,c)){let u=re(s,l),d=ce(h,c);rm(t,e,n,u,d,i,r,o)}else{let u=ne(s);hn(u,a,n,r,o)&&ju(u,t,e,n,i,r,o);let d=ie(s,l);hn(d,a,n,r,o)&&ju(d,t,e,n,i,r,o)}}var eM=["x","y","z"];function dm(s,t,e,n,i,r){Xt.setBuffer(s._roots[t]);let o=null;return hn(0,Xt.float32Array,n,i,r)&&(o=Qu(0,s,e,n,i,r)),Xt.clearBuffer(),o}function Qu(s,t,e,n,i,r){let{float32Array:o,uint16Array:a,uint32Array:c}=Xt,l=s*2;if($t(l,a)){let f=re(s,c),u=ce(l,a);return om(t,e,n,f,u,i,r)}else{let f=Pr(s,c),u=eM[f],g=n.direction[u]>=0,v,m;g?(v=ne(s),m=ie(s,c)):(v=ie(s,c),m=ne(s));let x=hn(v,o,n,i,r)?Qu(v,t,e,n,i,r):null;if(x){let S=x.point[u];if(g?S<=o[m+f]:S>=o[m+f+3])return x}let y=hn(m,o,n,i,r)?Qu(m,t,e,n,i,r):null;return x&&y?x.distance<=y.distance?x:y:x||y||null}}var dl=new Jt,zr=new tn,kr=new tn,Jo=new _t,pm=new Ie,pl=new Ie;function mm(s,t,e,n){Xt.setBuffer(s._roots[t]);let i=tf(0,s,e,n);return Xt.clearBuffer(),i}function tf(s,t,e,n,i=null){let{float32Array:r,uint16Array:o,uint32Array:a}=Xt,c=s*2;if(i===null&&(e.boundingBox||e.computeBoundingBox(),pm.set(e.boundingBox.min,e.boundingBox.max,n),i=pm),$t(c,o)){let h=t.geometry,f=h.index,u=h.attributes.position,d=e.index,g=e.attributes.position,v=re(s,a),m=ce(c,o);if(Jo.copy(n).invert(),e.boundsTree)return fe(s,r,pl),pl.matrix.copy(Jo),pl.needsUpdate=!0,e.boundsTree.shapecast({intersectsBounds:x=>pl.intersectsBox(x),intersectsTriangle:x=>{x.a.applyMatrix4(n),x.b.applyMatrix4(n),x.c.applyMatrix4(n),x.needsUpdate=!0;for(let M=v*3,y=(m+v)*3;M<y;M+=3)if(de(kr,M,f,u),kr.needsUpdate=!0,x.intersectsTriangle(kr))return!0;return!1}});{let p=is(e);for(let x=v*3,M=(m+v)*3;x<M;x+=3){de(zr,x,f,u),zr.a.applyMatrix4(Jo),zr.b.applyMatrix4(Jo),zr.c.applyMatrix4(Jo),zr.needsUpdate=!0;for(let y=0,S=p*3;y<S;y+=3)if(de(kr,y,d,g),kr.needsUpdate=!0,zr.intersectsTriangle(kr))return!0}}}else{let h=ne(s),f=ie(s,a);return fe(h,r,dl),!!(i.intersectsBox(dl)&&tf(h,t,e,n,i)||(fe(f,r,dl),i.intersectsBox(dl)&&tf(f,t,e,n,i)))}}var ml=new _t,ef=new Ie,$o=new Ie,nM=new R,iM=new R,sM=new R,rM=new R;function gm(s,t,e,n={},i={},r=0,o=1/0){t.boundingBox||t.computeBoundingBox(),ef.set(t.boundingBox.min,t.boundingBox.max,e),ef.needsUpdate=!0;let a=s.geometry,c=a.attributes.position,l=a.index,h=t.attributes.position,f=t.index,u=mn.getPrimitive(),d=mn.getPrimitive(),g=nM,v=iM,m=null,p=null;i&&(m=sM,p=rM);let x=1/0,M=null,y=null;return ml.copy(e).invert(),$o.matrix.copy(ml),s.shapecast({boundsTraverseOrder:S=>ef.distanceToBox(S),intersectsBounds:(S,T,_)=>_<x&&_<o?(T&&($o.min.copy(S.min),$o.max.copy(S.max),$o.needsUpdate=!0),!0):!1,intersectsRange:(S,T)=>{if(t.boundsTree)return t.boundsTree.shapecast({boundsTraverseOrder:b=>$o.distanceToBox(b),intersectsBounds:(b,I,E)=>E<x&&E<o,intersectsRange:(b,I)=>{for(let E=b,L=b+I;E<L;E++){de(d,3*E,f,h),d.a.applyMatrix4(e),d.b.applyMatrix4(e),d.c.applyMatrix4(e),d.needsUpdate=!0;for(let C=S,U=S+T;C<U;C++){de(u,3*C,l,c),u.needsUpdate=!0;let N=u.distanceToTriangle(d,g,m);if(N<x&&(v.copy(g),p&&p.copy(m),x=N,M=C,y=E),N<r)return!0}}}});{let _=is(t);for(let b=0,I=_;b<I;b++){de(d,3*b,f,h),d.a.applyMatrix4(e),d.b.applyMatrix4(e),d.c.applyMatrix4(e),d.needsUpdate=!0;for(let E=S,L=S+T;E<L;E++){de(u,3*E,l,c),u.needsUpdate=!0;let C=u.distanceToTriangle(d,g,m);if(C<x&&(v.copy(g),p&&p.copy(m),x=C,M=E,y=b),C<r)return!0}}}}}),mn.releasePrimitive(u),mn.releasePrimitive(d),x===1/0?null:(n.point?n.point.copy(v):n.point=v.clone(),n.distance=x,n.faceIndex=M,i&&(i.point?i.point.copy(p):i.point=p.clone(),i.point.applyMatrix4(ml),v.applyMatrix4(ml),i.distance=v.sub(i.point).length(),i.faceIndex=y),n)}function _m(s,t=null){t&&Array.isArray(t)&&(t=new Set(t));let e=s.geometry,n=e.index?e.index.array:null,i=e.attributes.position,r,o,a,c,l=0,h=s._roots;for(let u=0,d=h.length;u<d;u++)r=h[u],o=new Uint32Array(r),a=new Uint16Array(r),c=new Float32Array(r),f(0,l),l+=r.byteLength;function f(u,d,g=!1){let v=u*2;if($t(v,a)){let m=re(u,o),p=ce(v,a),x=1/0,M=1/0,y=1/0,S=-1/0,T=-1/0,_=-1/0;for(let b=m,I=m+p;b<I;b++){let E=3*s.resolveTriangleIndex(b);for(let L=0;L<3;L++){let C=E+L;C=n?n[C]:C;let U=i.getX(C),N=i.getY(C),B=i.getZ(C);U<x&&(x=U),U>S&&(S=U),N<M&&(M=N),N>T&&(T=N),B<y&&(y=B),B>_&&(_=B)}}return c[u+0]!==x||c[u+1]!==M||c[u+2]!==y||c[u+3]!==S||c[u+4]!==T||c[u+5]!==_?(c[u+0]=x,c[u+1]=M,c[u+2]=y,c[u+3]=S,c[u+4]=T,c[u+5]=_,!0):!1}else{let m=ne(u),p=ie(u,o),x=g,M=!1,y=!1;if(t){if(!x){let E=m/8+d/32,L=p/8+d/32;M=t.has(E),y=t.has(L),x=!M&&!y}}else M=!0,y=!0;let S=x||M,T=x||y,_=!1;S&&(_=f(m,d,x));let b=!1;T&&(b=f(p,d,x));let I=_||b;if(I)for(let E=0;E<3;E++){let L=m+E,C=p+E,U=c[L],N=c[L+3],B=c[C],G=c[C+3];c[u+E]=U<B?U:B,c[u+E+3]=N>G?N:G}return I}}}function xm(s,t,e,n,i,r,o){Xt.setBuffer(s._roots[t]),hn(0,Xt.float32Array,n,r,o)&&nf(0,s,e,n,i,r,o),Xt.clearBuffer()}function nf(s,t,e,n,i,r,o){let{float32Array:a,uint16Array:c,uint32Array:l}=Xt,h=s*2;if($t(h,c)){let u=re(s,l),d=ce(h,c);lm(t,e,n,u,d,i,r,o)}else{let u=ne(s);hn(u,a,n,r,o)&&nf(u,t,e,n,i,r,o);let d=ie(s,l);hn(d,a,n,r,o)&&nf(d,t,e,n,i,r,o)}}var oM=["x","y","z"];function ym(s,t,e,n,i,r){Xt.setBuffer(s._roots[t]);let o=null;return hn(0,Xt.float32Array,n,i,r)&&(o=sf(0,s,e,n,i,r)),Xt.clearBuffer(),o}function sf(s,t,e,n,i,r){let{float32Array:o,uint16Array:a,uint32Array:c}=Xt,l=s*2;if($t(l,a)){let f=re(s,c),u=ce(l,a);return hm(t,e,n,f,u,i,r)}else{let f=Pr(s,c),u=oM[f],g=n.direction[u]>=0,v,m;g?(v=ne(s),m=ie(s,c)):(v=ie(s,c),m=ne(s));let x=hn(v,o,n,i,r)?sf(v,t,e,n,i,r):null;if(x){let S=x.point[u];if(g?S<=o[m+f]:S>=o[m+f+3])return x}let y=hn(m,o,n,i,r)?sf(m,t,e,n,i,r):null;return x&&y?x.distance<=y.distance?x:y:x||y||null}}var gl=new Jt,Vr=new tn,Gr=new tn,jo=new _t,vm=new Ie,_l=new Ie;function Mm(s,t,e,n){Xt.setBuffer(s._roots[t]);let i=rf(0,s,e,n);return Xt.clearBuffer(),i}function rf(s,t,e,n,i=null){let{float32Array:r,uint16Array:o,uint32Array:a}=Xt,c=s*2;if(i===null&&(e.boundingBox||e.computeBoundingBox(),vm.set(e.boundingBox.min,e.boundingBox.max,n),i=vm),$t(c,o)){let h=t.geometry,f=h.index,u=h.attributes.position,d=e.index,g=e.attributes.position,v=re(s,a),m=ce(c,o);if(jo.copy(n).invert(),e.boundsTree)return fe(s,r,_l),_l.matrix.copy(jo),_l.needsUpdate=!0,e.boundsTree.shapecast({intersectsBounds:x=>_l.intersectsBox(x),intersectsTriangle:x=>{x.a.applyMatrix4(n),x.b.applyMatrix4(n),x.c.applyMatrix4(n),x.needsUpdate=!0;for(let M=v,y=m+v;M<y;M++)if(de(Gr,3*t.resolveTriangleIndex(M),f,u),Gr.needsUpdate=!0,x.intersectsTriangle(Gr))return!0;return!1}});{let p=is(e);for(let x=v,M=m+v;x<M;x++){let y=t.resolveTriangleIndex(x);de(Vr,3*y,f,u),Vr.a.applyMatrix4(jo),Vr.b.applyMatrix4(jo),Vr.c.applyMatrix4(jo),Vr.needsUpdate=!0;for(let S=0,T=p*3;S<T;S+=3)if(de(Gr,S,d,g),Gr.needsUpdate=!0,Vr.intersectsTriangle(Gr))return!0}}}else{let h=ne(s),f=ie(s,a);return fe(h,r,gl),!!(i.intersectsBox(gl)&&rf(h,t,e,n,i)||(fe(f,r,gl),i.intersectsBox(gl)&&rf(f,t,e,n,i)))}}var xl=new _t,of=new Ie,Qo=new Ie,aM=new R,cM=new R,lM=new R,hM=new R;function Sm(s,t,e,n={},i={},r=0,o=1/0){t.boundingBox||t.computeBoundingBox(),of.set(t.boundingBox.min,t.boundingBox.max,e),of.needsUpdate=!0;let a=s.geometry,c=a.attributes.position,l=a.index,h=t.attributes.position,f=t.index,u=mn.getPrimitive(),d=mn.getPrimitive(),g=aM,v=cM,m=null,p=null;i&&(m=lM,p=hM);let x=1/0,M=null,y=null;return xl.copy(e).invert(),Qo.matrix.copy(xl),s.shapecast({boundsTraverseOrder:S=>of.distanceToBox(S),intersectsBounds:(S,T,_)=>_<x&&_<o?(T&&(Qo.min.copy(S.min),Qo.max.copy(S.max),Qo.needsUpdate=!0),!0):!1,intersectsRange:(S,T)=>{if(t.boundsTree){let _=t.boundsTree;return _.shapecast({boundsTraverseOrder:b=>Qo.distanceToBox(b),intersectsBounds:(b,I,E)=>E<x&&E<o,intersectsRange:(b,I)=>{for(let E=b,L=b+I;E<L;E++){let C=_.resolveTriangleIndex(E);de(d,3*C,f,h),d.a.applyMatrix4(e),d.b.applyMatrix4(e),d.c.applyMatrix4(e),d.needsUpdate=!0;for(let U=S,N=S+T;U<N;U++){let B=s.resolveTriangleIndex(U);de(u,3*B,l,c),u.needsUpdate=!0;let G=u.distanceToTriangle(d,g,m);if(G<x&&(v.copy(g),p&&p.copy(m),x=G,M=U,y=E),G<r)return!0}}}})}else{let _=is(t);for(let b=0,I=_;b<I;b++){de(d,3*b,f,h),d.a.applyMatrix4(e),d.b.applyMatrix4(e),d.c.applyMatrix4(e),d.needsUpdate=!0;for(let E=S,L=S+T;E<L;E++){let C=s.resolveTriangleIndex(E);de(u,3*C,l,c),u.needsUpdate=!0;let U=u.distanceToTriangle(d,g,m);if(U<x&&(v.copy(g),p&&p.copy(m),x=U,M=E,y=b),U<r)return!0}}}}}),mn.releasePrimitive(u),mn.releasePrimitive(d),x===1/0?null:(n.point?n.point.copy(v):n.point=v.clone(),n.distance=x,n.faceIndex=M,i&&(i.point?i.point.copy(p):i.point=p.clone(),i.point.applyMatrix4(xl),v.applyMatrix4(xl),i.distance=v.sub(i.point).length(),i.faceIndex=y),n)}function af(s,t,e){return s===null?null:(s.point.applyMatrix4(t.matrixWorld),s.distance=s.point.distanceTo(e.ray.origin),s.object=t,s)}var yl=new Ie,vl=new ti,bm=new R,Tm=new _t,wm=new R,cf=["getX","getY","getZ"],Ml=class s extends cl{static serialize(t,e={}){e={cloneBuffers:!0,...e};let n=t.geometry,i=t._roots,r=t._indirectBuffer,o=n.getIndex(),a={version:1,roots:null,index:null,indirectBuffer:null};return e.cloneBuffers?(a.roots=i.map(c=>c.slice()),a.index=o?o.array.slice():null,a.indirectBuffer=r?r.slice():null):(a.roots=i,a.index=o?o.array:null,a.indirectBuffer=r),a}static deserialize(t,e,n={}){n={setIndex:!0,indirect:!!t.indirectBuffer,...n};let{index:i,roots:r,indirectBuffer:o}=t;t.version||(console.warn("MeshBVH.deserialize: Serialization format has been changed and will be fixed up. It is recommended to regenerate any stored serialized data."),c(r));let a=new s(e,{...n,[Wo]:!0});if(a._roots=r,a._indirectBuffer=o||null,n.setIndex){let l=e.getIndex();if(l===null){let h=new Te(t.index,1,!1);e.setIndex(h)}else l.array!==i&&(l.array.set(i),l.needsUpdate=!0)}return a;function c(l){for(let h=0;h<l.length;h++){let f=l[h],u=new Uint32Array(f),d=new Uint16Array(f);for(let g=0,v=f.byteLength/32;g<v;g++){let m=8*g,p=2*m;$t(p,d)||(u[m+6]=u[m+6]/8-g)}}}}get primitiveStride(){return 3}get resolveTriangleIndex(){return this.resolvePrimitiveIndex}constructor(t,e={}){e.maxLeafTris&&(console.warn('MeshBVH: "maxLeafTris" option has been deprecated. Use "targetLeafSize", instead.'),e={...e,targetLeafSize:e.maxLeafTris}),super(t,e)}shiftTriangleOffsets(t){return super.shiftPrimitiveOffsets(t)}writePrimitiveBounds(t,e,n){let i=this.geometry,r=this._indirectBuffer,o=i.attributes.position,a=i.index?i.index.array:null,l=(r?r[t]:t)*3,h=l+0,f=l+1,u=l+2;a&&(h=a[h],f=a[f],u=a[u]);for(let d=0;d<3;d++){let g=o[cf[d]](h),v=o[cf[d]](f),m=o[cf[d]](u),p=g;v<p&&(p=v),m<p&&(p=m);let x=g;v>x&&(x=v),m>x&&(x=m),e[n+d]=p,e[n+d+3]=x}return e}computePrimitiveBounds(t,e,n){let i=this.geometry,r=this._indirectBuffer,o=i.attributes.position,a=i.index?i.index.array:null,c=o.normalized;if(t<0||e+t-n.offset>n.length/6)throw new Error("MeshBVH: compute triangle bounds range is invalid.");let l=o.array,h=o.offset||0,f=3;o.isInterleavedBufferAttribute&&(f=o.data.stride);let u=["getX","getY","getZ"],d=n.offset;for(let g=t,v=t+e;g<v;g++){let p=(r?r[g]:g)*3,x=(g-d)*6,M=p+0,y=p+1,S=p+2;a&&(M=a[M],y=a[y],S=a[S]),c||(M=M*f+h,y=y*f+h,S=S*f+h);for(let T=0;T<3;T++){let _,b,I;c?(_=o[u[T]](M),b=o[u[T]](y),I=o[u[T]](S)):(_=l[M+T],b=l[y+T],I=l[S+T]);let E=_;b<E&&(E=b),I<E&&(E=I);let L=_;b>L&&(L=b),I>L&&(L=I);let C=(L-E)/2,U=T*2;n[x+U+0]=E+C,n[x+U+1]=C+(Math.abs(E)+C)*Cr}}return n}raycastObject3D(t,e,n=[]){let{material:i}=t;if(i===void 0)return;Tm.copy(t.matrixWorld).invert(),vl.copy(e.ray).applyMatrix4(Tm),wm.setFromMatrixScale(t.matrixWorld),bm.copy(vl.direction).multiply(wm);let r=bm.length(),o=e.near/r,a=e.far/r;if(e.firstHitOnly===!0){let c=this.raycastFirst(vl,i,o,a);c=af(c,t,e),c&&n.push(c)}else{let c=this.raycast(vl,i,o,a);for(let l=0,h=c.length;l<h;l++){let f=af(c[l],t,e);f&&n.push(f)}}return n}refit(t=null){return(this.indirect?_m:cm)(this,t)}raycast(t,e=pn,n=0,i=1/0){let r=this._roots,o=[],a=this.indirect?xm:fm;for(let c=0,l=r.length;c<l;c++)a(this,c,e,t,o,n,i);return o}raycastFirst(t,e=pn,n=0,i=1/0){let r=this._roots,o=null,a=this.indirect?ym:dm;for(let c=0,l=r.length;c<l;c++){let h=a(this,c,e,t,n,i);h!=null&&(o==null||h.distance<o.distance)&&(o=h)}return o}intersectsGeometry(t,e){let n=!1,i=this._roots,r=this.indirect?Mm:mm;for(let o=0,a=i.length;o<a&&(n=r(this,o,t,e),!n);o++);return n}shapecast(t){let e=mn.getPrimitive(),n=super.shapecast({...t,intersectsPrimitive:t.intersectsTriangle,scratchPrimitive:e,iterate:this.indirect?um:am});return mn.releasePrimitive(e),n}bvhcast(t,e,n){let{intersectsRanges:i,intersectsTriangles:r}=n,o=mn.getPrimitive(),a=this.geometry.index,c=this.geometry.attributes.position,l=this.indirect?g=>{let v=this.resolveTriangleIndex(g);de(o,v*3,a,c)}:g=>{de(o,g*3,a,c)},h=mn.getPrimitive(),f=t.geometry.index,u=t.geometry.attributes.position,d=t.indirect?g=>{let v=t.resolveTriangleIndex(g);de(h,v*3,f,u)}:g=>{de(h,g*3,f,u)};if(r){if(!(t instanceof s))throw new Error('MeshBVH: "intersectsTriangles" callback can only be used with another MeshBVH.');let g=(v,m,p,x,M,y,S,T)=>{for(let _=p,b=p+x;_<b;_++){d(_),h.a.applyMatrix4(e),h.b.applyMatrix4(e),h.c.applyMatrix4(e),h.needsUpdate=!0;for(let I=v,E=v+m;I<E;I++)if(l(I),o.needsUpdate=!0,r(o,h,I,_,M,y,S,T))return!0}return!1};if(i){let v=i;i=function(m,p,x,M,y,S,T,_){return v(m,p,x,M,y,S,T,_)?!0:g(m,p,x,M,y,S,T,_)}}else i=g}return super.bvhcast(t,e,{intersectsRanges:i})}intersectsBox(t,e){return yl.set(t.min,t.max,e),yl.needsUpdate=!0,this.shapecast({intersectsBounds:n=>yl.intersectsBox(n),intersectsTriangle:n=>yl.intersectsTriangle(n)})}intersectsSphere(t){return this.shapecast({intersectsBounds:e=>t.intersectsBox(e),intersectsTriangle:e=>e.intersectsSphere(t)})}closestPointToGeometry(t,e,n={},i={},r=0,o=1/0){return(this.indirect?Sm:gm)(this,t,e,n,i,r,o)}closestPointToPoint(t,e={},n=0,i=1/0){return Qp(this,t,e,n,i)}};var Oi={r:[1,0,0,0],g:[0,1,0,0],b:[0,0,1,0],a:[0,0,0,1],l:[1/3,1/3,1/3,0]};function Sl(s,t=[1,1,1]){let e=s||t;return new Pt().setRGB(e[0],e[1],e[2],ee)}function Bi(s,t=[1,1,1]){let e=s||t;return new Pt().setRGB(e[0],e[1],e[2],Ke)}var bl=class{constructor(t,e,n,i){this.base=t,this.specs=e||{},this.loader=new si(i),this.maxAnisotropy=Math.min(8,n.capabilities.getMaxAnisotropy()),this.textures=new Map,this.made=new Map,this.baked=new Map,this.lightmaps=[],this.missed=new Set,this.water=[]}texture(t,e,n){if(!t)return null;let i=n.uv||[1,1,0,0],r=[t,e,i.join(","),!!n.clamp,!!n.nearest].join("|"),o=this.textures.get(r);if(o)return o;let a=this.textures.get(t);return a?(o=a.clone(),a._oCopies.push(o)):(o=this.loader.load(this.base+t,c=>{for(let l of c._oCopies)l.needsUpdate=!0}),o._oCopies=[],this.textures.set(t,o)),o.flipY=!1,o.colorSpace=e?ee:Ke,o.wrapS=o.wrapT=n.clamp?xn:Hn,o.repeat.set(i[0],i[1]),o.offset.set(i[2],i[3]),n.nearest?(o.magFilter=xe,o.minFilter=xe,o.generateMipmaps=!1):(o.magFilter=we,o.minFilter=Sn,o.anisotropy=this.maxAnisotropy),o.needsUpdate=!0,this.textures.set(r,o),o}get(t){let e=this.made.get(t);if(e)return e;let n=this.specs[t];return e=n?this.make(n,t):new Xn({color:11579568,roughness:.8,name:t}),this.made.set(t,e),e}make(t,e){let n=Sl(t.color),i=t.color&&t.color.length>3?t.color[3]:1,r=t.side==="double"?Pe:t.side==="back"?Ne:pn,o={name:e,color:n,side:r};t.alpha==="blend"?(o.transparent=!0,o.opacity=i,o.depthWrite=!1):t.alpha==="mask"&&(o.alphaTest=t.cutoff??.5,o.alphaToCoverage=!0);let a=t.triplanar,c=a?{}:t,l=this.texture(t.map,!0,c);if(l&&t.uv2&&(l.channel=1),t.unshaded){let u=new Oe({...o,map:l});return u.vertexColors=!!t.vcol,u.userData.spec=t,u}if(t.kind==="water")return this.makeWater(t,e);let h=new Xn({...o,map:l,roughness:t.roughness??.8,metalness:t.metalness??0});h.vertexColors=!!t.vcol,h.userData.spec=t;let f={tri:!!a,triWorld:!!(a&&a.world),rough:null,metal:null,ao:null};if(t.roughMap&&(h.roughnessMap=this.texture(t.roughMap,!1,c),f.rough=Oi[t.roughCh]||Oi.g),t.metalMap&&(h.metalnessMap=this.texture(t.metalMap,!1,c),f.metal=Oi[t.metalCh]||Oi.b),t.normalMap){h.normalMap=this.texture(t.normalMap,!1,c);let u=t.normalScale??1;h.normalScale=new At(u,-u)}if(t.aoMap&&(h.aoMap=this.texture(t.aoMap,!1,c),f.ao=Oi[t.aoCh]||Oi.r),t.emissive&&(h.emissive=Sl(t.emissive),h.emissiveIntensity=t.emissiveEnergy??1,t.emissiveMap&&(h.emissiveMap=this.texture(t.emissiveMap,!0,c),t.emissiveAdd&&h.emissive.getHex()===0&&h.emissive.setRGB(1,1,1))),t.kind==="terrain"&&t.layers&&t.layers.length){let u=t.layers[0];f.tri=!0,f.triWorld=!0,h.userData.tri={scale:[1/(u.scale||2),1/(u.scale||2),1/(u.scale||2)],offset:[0,0,0],sharpness:4},h.color.multiply(Bi(u.tint)),h.roughness=u.roughness??.95}else a&&(h.userData.tri=a);return(t.solid_glass||t.alpha==="blend"&&i<.6)&&(h.envMapIntensity=1,h.roughness=Math.min(h.roughness,.08)),ta(h,f),h}makeWater(t,e){let n=new Xn({name:e,color:Bi(t.deep,[.02,.08,.1]),roughness:.06,metalness:0,transparent:!0,opacity:.9,depthWrite:!1});n.normalMap=uM();let i=t.wave_scale||.35;return n.normalScale=new At(.25*(t.wave_strength??.6),.25*(t.wave_strength??.6)),n.userData.spec=t,n.userData.tri={scale:[i*.5,i*.5,i*.5],offset:[0,0,0],sharpness:8},n.userData.water=!0,ta(n,{tri:!0,triWorld:!0,water:!0}),this.water.push(n),n}forProbe(t,e){if(!t.isMeshStandardMaterial)return t;let n=t.uuid+"|probe|"+e.index,i=this.baked.get(n);return i||(i=t.clone(),i._oLm=t._oLm,i._oVRange=t._oVRange,i.envMap=e.texture,i.envMapIntensity=1,ta(i,t.userData.flags||{}),t.userData.water&&this.water.push(i),e.materials.push(i),this.baked.set(n,i),i)}forCorners(t,e,n){if(!t.isMeshStandardMaterial)return t;let i=t.uuid+"|corners|"+(e.env??1),r=this.baked.get(i);return r||(r=t.clone(),r.vertexColors=!0,r._oVRange=n*Math.PI,r.envMapIntensity=(t.envMapIntensity??1)*(e.env??1),ta(r,{...t.userData.flags||{},baked:!0,corners:!0}),this.baked.set(i,r),r)}forBaked(t,e){if(!e||!t.isMeshStandardMaterial)return t;let n=e.uv??1,i=t.uuid+"|"+e.atlas+"|"+n+"|"+e.rect.join(","),r=this.baked.get(i);if(r)return r;let o=this.lightmaps[e.atlas];if(!o)return t;r=t.clone();let a=o.texture;n!==1&&(o.sets=o.sets||{},a=o.sets[n],a||(a=o.sets[n]=o.texture.clone(),a.channel=n,a.needsUpdate=!0)),r.lightMap=a,r.lightMapIntensity=o.range*Math.PI;let c=.5/o.size,[l,h,f,u]=e.rect;return r._oLm=new Zt(l+c,h+c,Math.max(f-2*c,0),Math.max(u-2*c,0)),r.envMapIntensity=(t.envMapIntensity??1)*(e.env??1),ta(r,{...t.userData.flags||{},baked:!0}),this.baked.set(i,r),r}tick(t){for(let e of this.water)e._oShader&&(e._oShader.uniforms.oTime.value+=t)}},ss=null;function uM(){if(ss)return ss;let s=128,t=document.createElement("canvas");t.width=t.height=s;let e=t.getContext("2d"),n=e.createImageData(s,s),i=(r,o)=>{let a=0;for(let[c,l,h,f]of[[1,2,1,0],[3,1,.5,1.3],[2,5,.3,2.1],[7,3,.15,.7],[5,8,.1,4.2]])a+=h*Math.sin((r*c+o*l)*2*Math.PI/s+f);return a};for(let r=0;r<s;r++)for(let o=0;o<s;o++){let a=(i(o+1,r)-i(o-1,r))*.6,c=(i(o,r+1)-i(o,r-1))*.6,l=Math.hypot(a,c,1),h=(r*s+o)*4;n.data[h]=(-a/l*.5+.5)*255,n.data[h+1]=(-c/l*.5+.5)*255,n.data[h+2]=(1/l*.5+.5)*255,n.data[h+3]=255}return e.putImageData(n,0,0),ss=new Ai(t),ss.wrapS=ss.wrapT=Hn,ss.flipY=!1,ss.anisotropy=4,ss}function ve(s,t,e,n){return s.includes(t)?s.replace(t,e):(console.warn("Oriel: the viewer and this three.js do not fit ("+n+")"),s)}var fM=`
#ifdef ORIEL_TRI
	varying vec3 oWPos;
	varying vec3 oWNrm;
#endif
`,dM=`
#ifdef ORIEL_TRI
	#ifdef ORIEL_TRI_WORLD
		mat4 oM = modelMatrix;
		#ifdef USE_INSTANCING
			oM = modelMatrix * instanceMatrix;
		#endif
		oWPos = ( oM * vec4( transformed, 1.0 ) ).xyz;
		oWNrm = normalize( mat3( oM ) * objectNormal );
	#else
		oWPos = transformed;
		oWNrm = normalize( objectNormal );
	#endif
#endif
`,pM=`
uniform vec4 oRoughCh;
uniform vec4 oMetalCh;
uniform vec4 oAoCh;
#ifdef ORIEL_BAKED
	uniform vec4 oLm;
	uniform float oVRange;
#endif
#ifdef ORIEL_TRI
	varying vec3 oWPos;
	varying vec3 oWNrm;
	uniform vec3 oTriScale;
	uniform vec3 oTriOffset;
	uniform float oTriSharp;
	uniform float oTime;
	vec3 oTriW;
	vec3 oTriP;
	// The picture from three sides, as Godot lays it: more of the side the surface faces.
	vec4 oTri( sampler2D t ) {
		return texture2D( t, oTriP.xy ) * oTriW.z + texture2D( t, oTriP.xz ) * oTriW.y + texture2D( t, oTriP.zy * vec2( - 1.0, 1.0 ) ) * oTriW.x;
	}
	#define O_TEX( t, uv ) oTri( t )
#else
	#define O_TEX( t, uv ) texture2D( t, uv )
#endif
`,mM=`
#ifdef ORIEL_TRI
	oTriW = pow( abs( normalize( oWNrm ) ), vec3( oTriSharp ) );
	oTriW /= max( oTriW.x + oTriW.y + oTriW.z, 0.0001 );
	oTriP = ( oWPos * oTriScale + oTriOffset ) * vec3( 1.0, - 1.0, 1.0 );
	#ifdef ORIEL_WATER
		oTriP.xz += vec2( oTime * 0.03, oTime * 0.021 );
	#endif
#endif
`,gM=`
#ifdef ORIEL_TRI
	#ifdef USE_NORMALMAP
		vec3 oAn = abs( normalize( oWNrm ) );
		vec3 oT = normalize( vec3( 0.0, 0.0, - 1.0 ) * oAn.x + vec3( 1.0, 0.0, 0.0 ) * ( oAn.y + oAn.z ) );
		vec3 oB = normalize( vec3( 0.0, 1.0, 0.0 ) * ( oAn.x + oAn.z ) + vec3( 0.0, 0.0, - 1.0 ) * oAn.y );
		vec3 oNm = oTri( normalMap ).xyz * 2.0 - 1.0;
		#ifdef ORIEL_WATER
			vec3 oNm2 = texture2D( normalMap, oTriP.xz * 1.7 + vec2( - oTime * 0.05, oTime * 0.02 ) ).xyz * 2.0 - 1.0;
			oNm.xy = ( oNm.xy + oNm2.xy ) * 0.5;
		#endif
		oNm.xy *= abs( normalScale.x );
		oNm.z = sqrt( saturate( 1.0 - dot( oNm.xy, oNm.xy ) ) );
		vec3 oNw = normalize( oWNrm );
		oNw = normalize( oT * oNm.x + oB * oNm.y + oNw * oNm.z );
		#ifdef ORIEL_TRI_WORLD
			normal = normalize( mat3( viewMatrix ) * oNw );
		#else
			normal = normalize( normalMatrix * oNw );
		#endif
		#ifdef DOUBLE_SIDED
			normal *= faceDirection;
		#endif
	#endif
#else
`,_M=`
#ifdef USE_ALPHATEST
	#ifdef ALPHA_TO_COVERAGE
		diffuseColor.a = clamp( ( diffuseColor.a - alphaTest ) / max( fwidth( diffuseColor.a ), 0.0001 ) + 0.5, 0.0, 1.0 );
		if ( diffuseColor.a == 0.0 ) discard;
	#else
		if ( diffuseColor.a < alphaTest ) discard;
	#endif
#endif
`;function ta(s,t){s.userData.flags=t;let e=["o",t.tri?1:0,t.triWorld?1:0,t.baked?1:0,t.water?1:0,t.corners?1:0].join("");s.customProgramCacheKey=()=>e,s.onBeforeCompile=n=>{let i=s.userData.tri||{scale:[1,1,1],offset:[0,0,0],sharpness:1},r=s.userData.flags;n.uniforms.oRoughCh={value:new Zt(...r.rough||Oi.g)},n.uniforms.oMetalCh={value:new Zt(...r.metal||Oi.b)},n.uniforms.oAoCh={value:new Zt(...r.ao||Oi.r)},n.uniforms.oTriScale={value:new R(...i.scale)},n.uniforms.oTriOffset={value:new R(...i.offset||[0,0,0])},n.uniforms.oTriSharp={value:i.sharpness??1},n.uniforms.oTime={value:0},n.uniforms.oLm={value:s._oLm||new Zt(0,0,1,1)},n.uniforms.oVRange={value:s._oVRange??1};let o=(r.tri?`#define ORIEL_TRI
`:"")+(r.triWorld?`#define ORIEL_TRI_WORLD
`:"")+(r.baked?`#define ORIEL_BAKED
`:"")+(r.water?`#define ORIEL_WATER
`:"")+(r.corners?`#define ORIEL_CORNERS
`:""),a=n.vertexShader;a=ve(a,"#include <common>",`#include <common>
`+fM,"common"),a=ve(a,"#include <project_vertex>",dM+`
#include <project_vertex>`,"project"),n.vertexShader=o+a;let c=n.fragmentShader;c=ve(c,"#include <common>",`#include <common>
`+pM,"common"),c=ve(c,"#include <map_fragment>",mM+ve(Nt.map_fragment,"texture2D( map, vMapUv )","O_TEX( map, vMapUv )","map"),"map chunk"),c=ve(c,"#include <roughnessmap_fragment>",ve(ve(Nt.roughnessmap_fragment,"texture2D( roughnessMap, vRoughnessMapUv )","O_TEX( roughnessMap, vRoughnessMapUv )","roughness"),"texelRoughness.g","dot( texelRoughness, oRoughCh )","roughness channel"),"roughness chunk"),c=ve(c,"#include <metalnessmap_fragment>",ve(ve(Nt.metalnessmap_fragment,"texture2D( metalnessMap, vMetalnessMapUv )","O_TEX( metalnessMap, vMetalnessMapUv )","metalness"),"texelMetalness.b","dot( texelMetalness, oMetalCh )","metalness channel"),"metalness chunk"),c=ve(c,"#include <emissivemap_fragment>",ve(Nt.emissivemap_fragment,"texture2D( emissiveMap, vEmissiveMapUv )","O_TEX( emissiveMap, vEmissiveMapUv )","emissive"),"emissive chunk"),c=ve(c,"#include <aomap_fragment>",ve(Nt.aomap_fragment,"texture2D( aoMap, vAoMapUv ).r","dot( O_TEX( aoMap, vAoMapUv ), oAoCh )","ao"),"ao chunk");let l="vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;",h=ve(Nt.normal_fragment_maps,l,l+`
	mapN.z = sqrt( saturate( 1.0 - dot( mapN.xy, mapN.xy ) ) );`,"normal");c=ve(c,"#include <normal_fragment_maps>",gM+h+`
#endif
`,"normal chunk");let f=ve(Nt.lights_fragment_maps,"texture2D( lightMap, vLightMapUv )","texture2D( lightMap, clamp( vLightMapUv, 0.0, 1.0 ) * oLm.zw + oLm.xy )","lightmap");f=ve(f,"#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_PMREM )","#if defined( USE_ENVMAP ) && defined( ENVMAP_TYPE_PMREM ) && ! defined( ORIEL_BAKED )","ibl"),f=ve(f,"#ifdef USE_LIGHTMAP",`#ifdef ORIEL_CORNERS
		irradiance += vColor.rgb * vColor.rgb * oVRange;
	#endif
	#ifdef USE_LIGHTMAP`,"corner light"),r.corners&&(c=ve(c,"#include <color_fragment>","","colours")),c=ve(c,"#include <lights_fragment_maps>",r.baked?f:Nt.lights_fragment_maps,"lights chunk"),c=ve(c,"#include <alphatest_fragment>",_M,"alpha test"),r.baked&&(c=ve(c,"vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;","vec3 totalDiffuse = reflectedLight.indirectDiffuse;","total diffuse")),n.fragmentShader=o+c,s._oShader=n},s.needsUpdate=!0}var xM={linear:Co,reinhard:Po,filmic:Io,aces:vr,agx:Lo},yM=12;function Tl(s,t=new _t){return t.set(s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9],s[10],s[11],0,0,0,1)}function vM(s){try{let n=document.createElement("canvas");n.width=64,n.height=32;let i=n.getContext("2d",{willReadFrequently:!0});i.drawImage(s,0,0,64,32);let r=i.getImageData(0,0,64,32/2).data,o=l=>(l/=255,l<=.04045?l/12.92:Math.pow((l+.055)/1.055,2.4)),a=0,c=0;for(let l=0;l<32/2;l++){let h=Math.cos((.5-(l+.5)/32)*Math.PI);for(let f=0;f<64;f++){let u=(l*64+f)*4;a+=Math.log(.2126*o(r[u])+.7152*o(r[u+1])+.0722*o(r[u+2])+.002)*h,c+=h}}return c>0?Math.exp(a/c):0}catch{return 0}}var wl=class s{constructor(t){this.app=t,this.data=t.data,this.base=t.base,this.objects=new Map,this.meshes=new Map,this.baked=!!(this.data.bake&&this.data.bake.objects),this.bounds=new Jt,this.pending=[],this.probes=[],this.root=new Ye,this.root.name="oriel",t.scene.add(this.root)}async load(t){let{app:e,data:n}=this,i=e.renderer;this.mats=new bl(this.base,n.materials,i,e.manager),i.toneMapping=xM[(n.post||{}).tonemap]??vr,i.toneMappingExposure=(n.post||{}).exposure??1;let r=[this.loadSky(),this.loadShapes(t)];this.baked&&r.push(this.loadLightmaps());let[,o]=await Promise.all(r);this.build(o),this.lights(),this.fog(),this.texts();let a=n.bounds;a&&a.length===6?this.bounds.set(new R(a[0],a[1],a[2]),new R(a[3],a[4],a[5])):this.bounds.setFromObject(this.root),this.root.updateMatrixWorld(!0),this.collide()}loadSky(){let t=this.data.world||{},e=this.app.scene;if(!t.sky){let n=t.color||t.horizon||[.05,.05,.05];return e.background=Bi(n),this.app.scene.add(new bo(Bi(n),Math.PI*(t.ambient??1))),Promise.resolve()}return new Promise(n=>{new si(this.app.manager).load(this.base+t.sky,i=>{i.mapping=Sr,i.colorSpace=ee,e.background=i;let r=new Is(this.app.renderer);e.environment=r.fromEquirectangular(i).texture,e.environmentIntensity=t.ambient??1,r.dispose(),this.reference=vM(i.image),n()},void 0,()=>n())})}loadShapes(t){return new Promise((e,n)=>{new Jc(this.app.manager).load(this.base+"scene.glb",e,i=>{t&&i.total&&t(i.loaded/i.total)},n)})}async loadLightmaps(){let t=this.data.bake,e=new si(this.app.manager);await Promise.all((t.atlases||[]).map((n,i)=>new Promise(r=>{if(!n.file)return r();e.load(this.base+n.file,o=>{o.flipY=!1,o.colorSpace=ee,o.channel=1,o.generateMipmaps=!1,o.minFilter=o.magFilter=we,this.mats.lightmaps[i]={texture:o,range:n.range??1,size:n.size??o.image.width},r()},void 0,()=>r())})))}static partsOf(t){let e=[];return t.traverse(n=>{n.isMesh&&e.push(n)}),e}dress(t,e){let n=this.baked?this.data.bake.objects[e]:null,i=this.mats.get(t.userData.oMat??t.material.name);if(t.userData.oMat=i.name,n&&n.vertex){t.material=t.geometry.attributes.color?this.mats.forCorners(i,n,this.data.bake.vertex_range??1):i;return}t.material=n?this.mats.forBaked(i,n):i,n&&!t.geometry.attributes["uv"+(n.uv??1)]&&(t.material=i)}dressed(t,e){this.dress(t,e);let n=this.probes[t.userData.oProbe];n&&(t.material=this.mats.forProbe(t.material,n))}probePlaces(t){let e=[];for(let n of this.data.views||[]){let i=new R(...n.position);e.every(r=>r.distanceTo(i)>2.5)&&e.push(i)}if(!e.length){let n=this.bounds.getCenter(new R);e.push(new R(n.x,this.bounds.min.y+1.5,n.z))}return e.slice(0,t)}async reflect(t){let{app:e}=this;if(!this.baked||e.noProbes)return;let n=e.renderer,i=this.probePlaces(e.light?2:6),r=e.light?64:128,o=new Ps(r,{type:cn}),a=new Ji(.05,2e3,o),c=new Is(n);this.root.updateMatrixWorld(!0);let l=f=>{a.position.copy(f.at),a.update(n,e.scene);let u=f.texture;f.texture=c.fromCubemap(o.texture).texture;for(let d of f.materials)d.envMap=f.texture;u&&u.dispose()},h=i.map((f,u)=>({at:f,index:u,texture:null,materials:[]}));for(let f=0;f<2;f++){for(let u of h)l(u),t&&t((f*h.length+u.index+1)/(h.length*2)),await new Promise(d=>setTimeout(d,0));f===0&&(this.probes=h,this.place())}o.dispose(),c.dispose()}place(){let t=new Jt,e=new R,n=new R,i=new R,r=o=>{if(t.setFromObject(o),t.isEmpty())return-1;t.getCenter(e);let a=t.getSize(i).length()*.5,c=-1,l=1/0;for(let h of this.probes){let f=h.at.distanceTo(e);if(!(f>=l)){if(f>a){n.copy(e).sub(h.at).normalize();let u=this.app.nav.cast(h.at,n,f);if(u&&u.distance<f-a*1.05-.05)continue}c=h.index,l=f}}return c};for(let[o,a]of this.meshes)for(let c of a)c.userData.oProbe=r(c),this.dressed(c,o);this.root.traverse(o=>{if(!o.isInstancedMesh)return;let a=this.probes[r(o)];a&&(o.material=this.mats.forProbe(o.material,a))})}build(t){let{data:e}=this,n=e.objects||{},i=new Map;t.scene.updateMatrixWorld(!0),t.scene.traverse(c=>{n[c.name]&&!i.has(c.name)&&i.set(c.name,c)});let r=!this.baked,o=(c,l,h,f=!1)=>{let u=s.partsOf(l);for(let d of u)d.geometry.attributes.tangent&&d.geometry.deleteAttribute("tangent"),this.dress(d,c),d.castShadow=r&&h.cast_shadow!==!1,d.receiveShadow=r,d.userData.oName=c;l.visible=!h.hidden&&!h.shadow_only,l.userData.oName=c,this.objects.set(c,l),this.meshes.set(c,u),f?this.root.add(l):this.root.attach(l)};for(let[c,l]of Object.entries(n)){if(l.base||l.copy_of)continue;let h=i.get(c);h&&o(c,h,l)}let a=new _t;for(let[c,l]of Object.entries(n)){if(!l.copy_of)continue;let h=i.get(l.copy_of);if(!h)continue;let f=h.clone(!0);f.name=c,f.traverse(u=>{u.isMesh&&(u.userData={oMat:u.userData.oMat??u.material.name})}),Tl(l.xform,a),f.matrix.copy(a),f.matrix.decompose(f.position,f.quaternion,f.scale),o(c,f,l,!0)}for(let[c,l]of(e.instancers||[]).entries()){let h=i.get(l.base);h&&this.pending.push(this.scatter(h,l,c))}}async scatter(t,e,n){let i=await fetch(this.base+e.file),r=new Float32Array(await i.arrayBuffer()),o=Math.min(e.count,Math.floor(r.length/12)),a=new _t,c=new _t;t.updateMatrixWorld(!0);let l=new Ye;l.name=e.base;for(let h of s.partsOf(t)){h.geometry.attributes.tangent&&h.geometry.deleteAttribute("tangent");let f=this.mats.get(h.material.name),u=new ys(h.geometry,f,o);c.copy(h.matrixWorld);for(let d=0;d<o;d++)Tl(r.subarray(d*12,d*12+12),a).multiply(c),u.setMatrixAt(d,a);u.instanceMatrix.needsUpdate=!0,u.castShadow=!this.baked,u.receiveShadow=!this.baked,u.computeBoundingSphere(),u.computeBoundingBox(),u.userData.oName=e.base,l.add(u)}l.visible=!e.hidden,this.objects.set(e.base,l),this.root.add(l),this.app.shadowsChanged()}lights(){let{data:t,app:e}=this,i=(t.world||{}).sun;if(i&&i.energy>0){let a=new bs(Bi(i.color),i.energy*Math.PI),c=new R(...i.toward).normalize(),l=t.bounds&&t.bounds.length===6?t.bounds:[-30,0,-30,30,10,30],h=new R((l[0]+l[3])/2,(l[1]+l[4])/2,(l[2]+l[5])/2),f=Math.min(Math.hypot(l[3]-l[0],l[4]-l[1],l[5]-l[2])/2+4,140);if(a.position.copy(h).addScaledVector(c,f*2),a.target.position.copy(h),!this.baked&&i.shadow!==!1){a.castShadow=!0;let u=e.light?2048:4096;a.shadow.mapSize.set(u,u);let d=a.shadow.camera;d.left=d.bottom=-f,d.right=d.top=f,d.near=.5,d.far=f*4,d.updateProjectionMatrix(),a.shadow.bias=-4e-4,a.shadow.normalBias=f/u*3,a.shadow.autoUpdate=!1,a.shadow.needsUpdate=!0,e.renderer.shadowMap.enabled=!0}e.scene.add(a,a.target),this.sun=a}if(this.baked)return;let r=(t.lights||[]).filter(a=>a.type==="point"||a.type==="spot").sort((a,c)=>c.energy-a.energy).slice(0,yM),o=new _t;for(let a of r){Tl(a.matrix,o);let c=new R().setFromMatrixPosition(o),l=Bi(a.color),h;if(a.type==="spot"){h=new Ms(l,a.energy*Math.PI,a.range||0,Math.min((a.spot_angle||45)*Math.PI/180,Math.PI/2-.01),Math.min(a.spot_blend??.3,1),a.decay??2);let f=new R(0,0,-1).transformDirection(o);h.target.position.copy(c).add(f),e.scene.add(h.target)}else h=new Ss(l,a.energy*Math.PI,a.range||0,a.decay??2);h.position.copy(c),e.scene.add(h)}}fog(){let t=this.data.fog||{};if(!(t.density>0))return;let e=Bi(t.color||[.6,.7,.8]).multiplyScalar(t.energy??1);this.app.scene.fog=new ro(e,Math.sqrt(t.density/150))}texts(){let t=new _t;for(let e of this.data.texts||[]){let n=String(e.text).split(`
`),i=64,r=document.createElement("canvas"),o=r.getContext("2d"),a=`600 ${i}px "JetBrains Mono", ui-monospace, monospace`;o.font=a;let c=Math.max(...n.map(d=>o.measureText(d).width),8);r.width=Math.ceil(c+i*.4),r.height=Math.ceil(n.length*i*1.25+i*.2),o.font=a,o.textBaseline="top",o.textAlign=e.align==="left"?"left":e.align==="right"?"right":"center",o.fillStyle="#"+Bi(e.color).getHexString(ee);let l=e.align==="left"?i*.2:e.align==="right"?r.width-i*.2:r.width/2;n.forEach((d,g)=>o.fillText(d,l,i*.1+g*i*1.25));let h=new Ai(r);h.colorSpace=ee,h.anisotropy=4;let f=(e.size||.2)*1.25*n.length,u=new Ee(new Ri(f*r.width/r.height,f),new Oe({map:h,transparent:!0,side:Pe,depthWrite:!1}));Tl(e.matrix,t),u.matrix.copy(t),u.matrix.decompose(u.position,u.quaternion,u.scale),u.userData.oText=!0,this.root.add(u)}}collide(){let t=[],e=0;for(let[c,l]of this.meshes){let h=this.objects.get(c);if(!(!h||!h.visible))for(let f of l){let u=f.material.userData&&f.material.userData.spec;if(u&&u.kind==="water")continue;let d=f.geometry.attributes.position;if(!d)continue;let g=f.geometry.index?f.geometry.index.count:d.count;t.push([c,f,g]),e+=g}}let n=new Float32Array(e*3),i=[],r=new R,o=0;for(let[c,l,h]of t){l.updateWorldMatrix(!0,!1);let f=l.geometry.attributes.position,u=l.geometry.index;i.push([o/9,c,l]);for(let d=0;d<h;d++)r.fromBufferAttribute(f,u?u.getX(d):d).applyMatrix4(l.matrixWorld),n[o++]=r.x,n[o++]=r.y,n[o++]=r.z}let a=new ye;a.setAttribute("position",new Te(n,3)),this.bvh=e>0?new Ml(a,{indirect:!0}):null,this.owners=i,this.triangles=e/3}ownerOf(t){let e=this.owners,n=0,i=e.length-1;for(;n<i;){let r=n+i+1>>1;e[r][0]<=t?n=r:i=r-1}return e.length?{name:e[n][1],mesh:e[n][2]}:null}showOption(t,e){t.options.forEach((n,i)=>{for(let r of n.objects){let o=this.objects.get(r);o&&(o.visible=i===e)}}),t.shown=e,this.collide(),this.app.shadowsChanged()}choose(t,e){for(let n of t.objects){let r=(this.meshes.get(n)||[])[t.slot];r&&(r.userData.oFirst===void 0&&(r.userData.oFirst=r.userData.oMat),r.userData.oMat=e<0?r.userData.oFirst:t.options[e].material,this.dressed(r,n))}t.chosen=e}tick(t){this.mats.tick(t)}};var VE=new R(0,1,0),Am=-18,Fs=.25,lf=5,hf=.6,fi=new R,Em=new R,Hr=new Jt,di=new Qe,Rm=new R,Cm=new R;function MM(s){return s*s*s*(s*(s*6-15)+10)}function SM(s,t){return s+me.euclideanModulo(t-s+Math.PI,Math.PI*2)-Math.PI}var Al=class{constructor(t){this.app=t;let e=t.data.options||{};this.eyeDefault=e.eye_height||1.6,this.speed=e.walk_speed||1.4,this.mode="walk",this.pos=new R,this.eye=this.eyeDefault,this.yaw=0,this.pitch=0,this.velY=0,this.onGround=!1,this.hover=!1,this.keys=new Set,this.move=null,this.tour=null,this.viewIndex=-1,this.lastInput=performance.now(),this.raycaster=new Ao,this.orbit={target:new R,distance:30,azimuth:.6,polar:1},this.top={centre:new R,span:40,cut:2.3},this.topCamera=new qn(-1,1,1,-1,.1,2e3),this.lastSafe=new R,this.pointers=new Map,this.bind()}get bvh(){return this.app.world.bvh}cast(t,e,n=1/0){let i=this.bvh;if(!i)return null;this.raycaster.ray.origin.copy(t),this.raycaster.ray.direction.copy(e).normalize();let r=i.raycastFirst(this.raycaster.ray,Pe,0,n);if(!r)return null;let o=r.face.normal.clone();return o.dot(this.raycaster.ray.direction)>0&&o.negate(),{point:r.point.clone(),normal:o,distance:r.distance,faceIndex:r.faceIndex}}floorUnder(t,e=.5,n=4){fi.set(t.x,t.y+e,t.z);let i=this.cast(fi,Em.set(0,-1,0),e+n);return i&&i.normal.y>hf?i.point.y:null}pick(t,e){let n=this.app,i=n.canvas.getBoundingClientRect(),r=new At((t-i.left)/i.width*2-1,-((e-i.top)/i.height)*2+1),o=this.mode==="top"?this.topCamera:n.camera;this.apply(),n.rig.updateMatrixWorld(!0),o.updateMatrixWorld(!0),this.raycaster.setFromCamera(r,o);let a=this.raycaster.ray,c=a.origin.clone(),l=a.direction.clone();this.mode!=="walk"&&this.cutting&&l.y<-.001&&c.y>this.top.cut&&c.addScaledVector(l,(this.top.cut-c.y)/l.y);let h=this.cast(c,l);return h&&(h.owner=n.world.ownerOf(h.faceIndex)),h}placeAt(t){this.move=null;let e=t.position,n=this.app.xr;if(n.presenting){let i=new R(e[0],e[1],e[2]),r=this.floorUnder(i,0,Math.max(this.eyeDefault*2.2,3.5));this.hover=r===null,n.placeHead(new R(e[0],r===null?e[1]-n.headLocal().y:r,e[2]),t.yaw);return}this.yaw=t.yaw,this.pitch=t.pitch,this.settle(new R(e[0],e[1],e[2])),this.apply()}settle(t){let e=this.floorUnder(t,0,Math.max(this.eyeDefault*2.2,3.5));e!==null&&t.y-e>.4?(this.pos.set(t.x,e,t.z),this.eye=t.y-e,this.hover=!1,this.onGround=!0):(this.pos.set(t.x,t.y-this.eyeDefault,t.z),this.eye=this.eyeDefault,this.hover=!0),this.velY=0,this.lastSafe.copy(this.pos)}eyePoint(t=new R){return t.set(this.pos.x,this.pos.y+this.eye,this.pos.z)}goToView(t,e={}){let n=this.app.data.views||[];if(!n.length)return;t=me.euclideanModulo(t,n.length);let i=n[t];this.viewIndex=t,this.setMode("walk",!0);let r=new R(...i.position),o=this.eyePoint(),a=o.distanceTo(r),c=a>.01&&this.cast(o,fi.copy(r).sub(o),a-.05)!==null,l=()=>{this.app.ui.viewChanged(t),e.then&&e.then()};e.instant||this.app.xr.presenting?(this.placeAt(i),this.app.eye&&this.app.eye.snap(),l()):c||a>60?this.app.ui.fade(()=>this.placeAt(i),l):this.glide(r,i.yaw,i.pitch,me.clamp(a/4,1.2,5),l)}glide(t,e,n,i,r){this.move={from:this.eyePoint(),to:t.clone(),yawFrom:this.yaw,yawTo:e===void 0?this.yaw:SM(this.yaw,e),pitchFrom:this.pitch,pitchTo:n===void 0?this.pitch:n,t:0,T:Math.max(i,.05),then:r}}walkTo(t){let e=new R(t.x,t.y+this.eyeDefault,t.z),n=this.eyePoint().distanceTo(e);this.hover=!1,this.glide(e,void 0,void 0,me.clamp(n/3.5,.35,4.5))}setMode(t,e=!1){if(t===this.mode)return;let n=this.app,i=n.world.bounds,r=i.getSize(new R),o=i.getCenter(new R);if(this.move=null,t==="orbit")this.orbit.target.copy(o),this.orbit.distance=Math.max(r.length()*.75,5),this.orbit.azimuth=this.yaw+Math.PI,this.orbit.polar=1;else if(t==="top"){this.top.centre.copy(o),this.top.span=Math.max(r.x,r.z)*1.15+2;let a=this.hover?i.min.y:this.pos.y;this.top.cut=Math.min(a+this.eyeDefault+.7,i.max.y+.01)}this.mode=t,this.cutting=t==="top",n.clip.constant=this.cutting?this.top.cut:1e7,n.activeCamera=t==="top"?this.topCamera:n.camera,e||n.ui.modeChanged(t),this.apply()}enterAt(t){this.setMode("walk"),this.settle(new R(t.x,t.y+this.eyeDefault,t.z)),this.pitch=0,this.apply()}bind(){let t=this.app.canvas,e=()=>{this.lastInput=performance.now(),this.stopTour()};window.addEventListener("keydown",i=>{if(i.target&&/input|textarea|select/i.test(i.target.tagName)||i.metaKey||i.ctrlKey||i.altKey)return;let r=!!this.tour;if(e(),this.keys.add(i.code),i.code==="KeyT"&&r){i.preventDefault();return}(this.app.ui.key(i)||/^(Arrow|Space|Page)/.test(i.code))&&i.preventDefault()}),window.addEventListener("keyup",i=>this.keys.delete(i.code)),window.addEventListener("blur",()=>this.keys.clear()),t.addEventListener("pointerdown",i=>{e(),t.setPointerCapture(i.pointerId),this.pointers.set(i.pointerId,{x:i.clientX,y:i.clientY,x0:i.clientX,y0:i.clientY,moved:!1,button:i.button,t:performance.now()}),this.pinch=this.pointers.size===2?this.pinchState():null}),t.addEventListener("pointermove",i=>{let r=this.pointers.get(i.pointerId);if(!r){this.app.ui.hover(i.clientX,i.clientY);return}let o=i.clientX-r.x,a=i.clientY-r.y;r.x=i.clientX,r.y=i.clientY,Math.hypot(r.x-r.x0,r.y-r.y0)>6&&(r.moved=!0),this.pointers.size===2?this.twoFingers():r.moved&&this.drag(o,a,r.button,i.shiftKey)});let n=i=>{let r=this.pointers.get(i.pointerId);this.pointers.delete(i.pointerId),this.pinch=null,r&&!r.moved&&i.type==="pointerup"&&performance.now()-r.t<600&&this.pointers.size===0&&this.click(i.clientX,i.clientY)};t.addEventListener("pointerup",n),t.addEventListener("pointercancel",n),t.addEventListener("wheel",i=>{i.preventDefault(),e();let r=Math.sign(i.deltaY)*Math.min(Math.abs(i.deltaY),120)/120;this.mode==="orbit"?this.orbit.distance=me.clamp(this.orbit.distance*(1+r*.12),1.5,2e3):this.mode==="top"?this.top.span=me.clamp(this.top.span*(1+r*.12),2,5e3):this.nudge(-r*.9)},{passive:!1}),t.addEventListener("contextmenu",i=>i.preventDefault())}pinchState(){let[t,e]=[...this.pointers.values()];return{d:Math.hypot(t.x-e.x,t.y-e.y),y:(t.y+e.y)/2}}twoFingers(){let t=this.pinchState(),e=this.pinch||t;for(let r of this.pointers.values())r.moved=!0;let n=(t.d-e.d)/200,i=(t.y-e.y)/200;this.mode==="orbit"?this.orbit.distance=me.clamp(this.orbit.distance*(1-n),1.5,2e3):this.mode==="top"?this.top.span=me.clamp(this.top.span*(1-n),2,5e3):(this.nudge(n*4),this.eye=me.clamp(this.eye+i,.4,3)),this.pinch=t}nudge(t){this.move=null,this.pending=(this.pending||0)+t}drag(t,e,n,i){if(this.mode==="walk")this.move=this.move&&this.move.then?this.move:null,this.yaw+=t*.0032,this.pitch=me.clamp(this.pitch+e*.0032,-1.45,1.45);else if(this.mode==="orbit")if(n===2||i){let o=this.orbit.distance*.0015;fi.set(-Math.cos(this.orbit.azimuth),0,Math.sin(this.orbit.azimuth)),this.orbit.target.addScaledVector(fi,t*o),this.orbit.target.y+=e*o}else this.orbit.azimuth-=t*.0032*1.4,this.orbit.polar=me.clamp(this.orbit.polar-e*.0032*1.4,.08,1.52);else{let o=this.top.span/this.app.canvas.clientHeight;this.top.centre.x-=t*o,this.top.centre.z-=e*o}}click(t,e){let n=this.app,i=this.pick(t,e);if(!n.ui.clicked(i,t,e)&&i){if(this.mode!=="walk"){i.normal.y>hf&&this.enterAt(i.point);return}if(i.normal.y>hf)this.walkTo(i.point);else{let r=i.point.clone().addScaledVector(i.normal,.6),o=this.floorUnder(r,.1,6);o!==null&&this.walkTo(new R(r.x,o,r.z))}}}startTour(){return(this.app.data.views||[]).length<2?!1:(this.tour={phase:"dwell",t:0,i:this.viewIndex>=0?this.viewIndex:0},this.viewIndex<0&&this.goToView(0,{instant:!0}),this.app.ui.tourChanged(!0),!0)}stopTour(){this.tour&&(this.tour=null,this.move=null,this.app.ui.tourChanged(!1))}tourTick(t){let e=this.tour;if(!(!e||this.move||this.app.ui.fading)&&(e.t+=t,this.yaw+=t*.04,e.t>4.5)){e.t=0,e.i+=1;let n=this.tour;this.goToView(e.i),this.tour=n}}update(t){let e=this.app;t=Math.min(t,.1);let n=e.data.options||{};if(!this.tour&&n.idle_tour_s>0&&performance.now()-this.lastInput>n.idle_tour_s*1e3&&!e.xr.presenting&&e.started&&this.startTour(),this.tourTick(t),this.mode==="walk")this.move?this.glideTick(t):e.xr.presenting||this.walkTick(t);else if(this.mode==="orbit"){let i=t*1.2;(this.keys.has("ArrowLeft")||this.keys.has("KeyA"))&&(this.orbit.azimuth-=i),(this.keys.has("ArrowRight")||this.keys.has("KeyD"))&&(this.orbit.azimuth+=i),(this.keys.has("ArrowUp")||this.keys.has("KeyW"))&&(this.orbit.distance*=1-i*.6),(this.keys.has("ArrowDown")||this.keys.has("KeyS"))&&(this.orbit.distance*=1+i*.6)}this.apply()}glideTick(t){let e=this.move;e.t+=t;let n=MM(Math.min(e.t/e.T,1));fi.lerpVectors(e.from,e.to,n),this.pos.set(fi.x,fi.y-this.eye,fi.z),this.yaw=me.lerp(e.yawFrom,e.yawTo,n),this.pitch=me.lerp(e.pitchFrom,e.pitchTo,n),e.t>=e.T&&(this.move=null,this.settle(e.to),e.then&&e.then())}walkTick(t){let e=this.keys,n=0,i=0,r=0;(e.has("KeyW")||e.has("ArrowUp"))&&(n+=1),(e.has("KeyS")||e.has("ArrowDown"))&&(n-=1),e.has("KeyD")&&(i+=1),e.has("KeyA")&&(i-=1),e.has("ArrowRight")&&(this.yaw-=t*1.6),e.has("ArrowLeft")&&(this.yaw+=t*1.6),(e.has("KeyE")||e.has("PageUp"))&&(r+=1),(e.has("KeyQ")||e.has("PageDown"))&&(r-=1);let o=e.has("ShiftLeft")||e.has("ShiftRight")?2.4:1,a=new R,c=fi.set(-Math.sin(this.yaw),0,-Math.cos(this.yaw)),l=Em.set(Math.cos(this.yaw),0,-Math.sin(this.yaw));if((n||i)&&a.addScaledVector(c,n).addScaledVector(l,i).normalize().multiplyScalar(this.speed*o*t),this.pending){let u=this.pending*Math.min(t*10,1);this.pending-=u,Math.abs(this.pending)<.002&&(this.pending=0),a.addScaledVector(c,u)}r&&(this.eye=me.clamp(this.eye+r*t*.8,.4,3));let h=a.lengthSq()>0;if(this.hover){if(h){let u=this.floorUnder(this.eyePoint(),0,400);u!==null?(this.eye=this.pos.y+this.eye-u,this.pos.y=u,this.hover=!1):this.pos.add(a)}return}if(h&&Math.abs(this.eye-this.eyeDefault)>.01&&!r&&this.eye>this.eyeDefault*1.35&&(this.eye=me.damp(this.eye,this.eyeDefault,3,t)),!this.bvh){this.pos.add(a);return}let f=t/lf;a.multiplyScalar(1/lf);for(let u=0;u<lf;u++)this.physics(f,a);this.pos.y<this.app.world.bounds.min.y-30?(this.pos.copy(this.lastSafe),this.velY=0):this.onGround&&this.lastSafe.copy(this.pos)}physics(t,e,n=this.pos,i=this.eye){this.velY=this.onGround?Am*t:this.velY+Am*t,n.y+=this.velY*t,n.add(e);let r=Math.max(i-.05,Fs*2);di.start.set(n.x,n.y+Fs,n.z),di.end.set(n.x,n.y+r,n.z),Hr.makeEmpty(),Hr.expandByPoint(di.start),Hr.expandByPoint(di.end),Hr.min.addScalar(-Fs),Hr.max.addScalar(Fs),this.bvh.shapecast({intersectsBounds:h=>h.intersectsBox(Hr),intersectsTriangle:h=>{let f=h.closestPointToSegment(di,Rm,Cm);if(f<Fs){let u=Fs-f,d=Cm.sub(Rm).normalize();di.start.addScaledVector(d,u),di.end.addScaledVector(d,u)}}});let o=di.start.x,a=di.start.y-Fs,c=di.start.z,l=a-n.y;this.onGround=l>Math.abs(t*this.velY*.25),n.set(o,a,c),this.onGround&&(this.velY=0)}apply(){let t=this.app,e=t.rig,n=t.camera;if(this.mode==="walk")e.position.copy(this.pos),e.rotation.set(0,this.yaw,0),t.xr.presenting||(n.position.set(0,this.eye,0),n.rotation.set(this.pitch,0,0,"YXZ"));else if(this.mode==="orbit"){let i=this.orbit;e.position.set(0,0,0),e.rotation.set(0,0,0),n.position.set(i.target.x+i.distance*Math.sin(i.polar)*Math.sin(i.azimuth),i.target.y+i.distance*Math.cos(i.polar),i.target.z+i.distance*Math.sin(i.polar)*Math.cos(i.azimuth)),n.lookAt(i.target)}else{let i=this.top,r=this.topCamera,o=t.canvas.clientWidth/Math.max(t.canvas.clientHeight,1);r.left=-i.span*o/2,r.right=i.span*o/2,r.top=i.span/2,r.bottom=-i.span/2,r.position.set(i.centre.x,t.world.bounds.max.y+50,i.centre.z),r.up.set(0,0,-1),r.lookAt(i.centre.x,0,i.centre.z),r.updateProjectionMatrix()}}here(){let t=this.eyePoint();return[t.x,t.y,t.z,this.yaw,this.pitch].map(e=>Math.round(e*100)/100)}};var rs=new R,gn=384;function Et(s,t={},...e){let n=document.createElement(s);for(let[i,r]of Object.entries(t))i==="class"?n.className=r:i==="text"?n.textContent=r:i.startsWith("on")?n.addEventListener(i.slice(2),r):r!==!1&&r!==null&&r!==void 0&&n.setAttribute(i,r===!0?"":r);for(let i of e)i&&n.append(i);return n}var ea=class{constructor(t){this.app=t,this.root=document.getElementById("oriel-ui"),this.fading=!1,this.markers=[],this.measure={on:!1,points:[],lines:[]},this.frame=0,this.cover()}cover(){let t=this.app.data||{};this.coverEl=Et("div",{class:"o-cover"},Et("div",{class:"o-cover-box"},Et("h1",{text:t.title||document.title}),t.subtitle?Et("p",{class:"o-sub",text:t.subtitle}):null,this.bar=Et("div",{class:"o-progress"},Et("i")),this.coverNote=Et("p",{class:"o-note",text:"Loading\u2026"}),this.startBtn=Et("button",{class:"o-primary",text:"Walk in",hidden:!0,onclick:()=>this.app.start()}),t.credit?Et("p",{class:"o-credit",text:t.credit}):null)),this.root.append(this.coverEl)}progress(t,e){this.bar.firstChild.style.width=Math.round(me.clamp(t,0,1)*100)+"%",e&&(this.coverNote.textContent=e)}failed(t){this.coverNote.textContent=t,this.coverNote.classList.add("o-bad"),this.bar.hidden=!0}ready(){this.bar.hidden=!0,this.coverNote.textContent=this.hint(),this.startBtn.hidden=!1,this.startBtn.focus()}hint(){return matchMedia("(pointer: coarse)").matches?"Drag to look. Tap the floor to walk there.":"Drag to look. Click the floor to walk there, or use W A S D."}build(){let t=this.app,e=t.data,n=e.options||{},i=e.views||[],r=(a,c,l,h="")=>Et("button",{class:"o-btn "+h,title:c,text:a,onclick:f=>{f.currentTarget.blur(),l(f)}});this.btns={};let o=Et("div",{class:"o-bar"},Et("span",{class:"o-title",text:e.title||""}),Et("span",{class:"o-gap"}),i.length?this.btns.views=r("Views","Places to go (keys: [ and ])",()=>this.toggle("views")):null,this.btns.walk=r("Walk","On foot (key: 1)",()=>t.nav.setMode("walk"),"o-on"),this.btns.orbit=r("Orbit","Round the outside (key: 2)",()=>t.nav.setMode("orbit")),this.btns.top=r("Plan","From above (key: 3)",()=>t.nav.setMode("top")),i.length>1?this.btns.tour=r("Tour","Go through the views by itself (key: T)",()=>this.tourToggle()):null,n.measure!==!1?this.btns.measure=r("Measure","Measure between two points (key: M)",()=>this.measureToggle()):null,(e.choices||[]).length+(e.switches||[]).length?this.btns.options=r("Options","Materials and alternatives to choose",()=>this.toggle("options")):null,e.sound?this.btns.sound=r("Sound","Sound on or off",()=>this.soundToggle()):null,this.btns.vr=r("VR","Walk through with a headset",()=>t.xr.toggle(),"o-vr"),r("\u26F6","Full screen (key: F)",()=>this.fullscreen()),r("?","How to move (key: H)",()=>this.toggle("help")));this.btns.vr.hidden=!0,this.panels={views:Et("div",{class:"o-panel o-views",hidden:!0},Et("h2",{text:"Views"}),...i.map((a,c)=>Et("button",{class:"o-item",text:a.name,onclick:()=>{this.toggle(null),t.nav.stopTour(),t.nav.goToView(c)}})),Et("button",{class:"o-item o-link",text:"Copy a link to where I am",onclick:()=>this.copyLink()})),options:this.optionsPanel(),help:this.helpPanel(),spot:Et("div",{class:"o-panel o-spot",hidden:!0})},this.toastEl=Et("div",{class:"o-toast",hidden:!0}),this.fadeEl=Et("div",{class:"o-fade"}),this.markerLayer=Et("div",{class:"o-markers"}),this.labelLayer=Et("div",{class:"o-labels"}),this.choiceBar=Et("div",{class:"o-choices",hidden:!0}),this.root.append(this.markerLayer,this.labelLayer,o,...Object.values(this.panels),this.choiceBar,this.toastEl,this.fadeEl),this.buildMarkers(),n.minimap!==!1&&this.buildPlan(),e.sound&&(this.audio=new Audio(t.base+e.sound.file),this.audio.loop=!0,this.audio.volume=e.sound.volume??.5),this.barEl=o}toggle(t){for(let[e,n]of Object.entries(this.panels))n.hidden=e!==t||!n.hidden;this.btns.views&&this.btns.views.classList.toggle("o-on",!this.panels.views.hidden),this.btns.options&&this.btns.options.classList.toggle("o-on",!this.panels.options.hidden)}helpPanel(){let t=[["Look","drag"],["Walk","click or tap the floor \xB7 W A S D \xB7 arrows"],["Faster","Shift"],["Higher, lower","E, Q"],["Next, previous view","] and ["],["Walk, orbit, plan","1, 2, 3"],["Tour","T"],["Measure","M"],["Full screen","F"],["On a phone","drag to look \xB7 tap to walk \xB7 two fingers apart to walk on"],["In a headset","point and pull the trigger to go there \xB7 left stick walks \xB7 right stick turns \xB7 A and B change view"]];return Et("div",{class:"o-panel o-help",hidden:!0},Et("h2",{text:"How to move"}),Et("dl",{},...t.flatMap(([e,n])=>[Et("dt",{text:e}),Et("dd",{text:n})])),this.app.data.credit?Et("p",{class:"o-credit",text:this.app.data.credit}):null,Et("p",{class:"o-credit",text:this.app.data.made_by?"Made with "+this.app.data.made_by:""}))}optionsPanel(){let t=this.app,e=t.data,n=Et("div",{class:"o-panel o-options",hidden:!0},Et("h2",{text:"Options"}));for(let i of e.switches||[]){let r=Et("div",{class:"o-set"},Et("h3",{text:i.name}));i.options.forEach((o,a)=>{r.append(Et("button",{class:"o-chip"+(a===i.shown?" o-on":""),text:o.name,onclick:c=>{t.world.showOption(i,a);for(let l of r.querySelectorAll(".o-chip"))l.classList.remove("o-on");c.currentTarget.classList.add("o-on"),this.planDirty=!0}}))}),n.append(r)}for(let i of e.choices||[]){i.chosen=-1;let r=Et("div",{class:"o-set"},Et("h3",{text:i.name}));this.swatches(i,r),n.append(r)}return n}swatches(t,e){let n=this.app,i=[{name:"As designed",index:-1},...t.options.map((r,o)=>({name:r.name,index:o,material:r.material}))];for(let r of i){let o=r.material?n.data.materials[r.material]:null,a=Et("button",{class:"o-chip o-swatch"+(r.index===t.chosen?" o-on":""),title:r.name,onclick:()=>{n.world.choose(t,r.index),this.syncChoice(t)}},Et("i"),Et("span",{text:r.name}));a.dataset.choice=t.name,a.dataset.index=r.index,o&&(a.firstChild.style.background="#"+Sl(o.color).getHexString(),o.map&&(a.firstChild.style.backgroundImage=`url("${n.base+o.map}")`)),e.append(a)}}syncChoice(t){for(let e of this.root.querySelectorAll(".o-swatch"))e.dataset.choice===t.name&&e.classList.toggle("o-on",Number(e.dataset.index)===t.chosen)}openChoice(t){this.choiceBar.replaceChildren(Et("span",{class:"o-choices-name",text:t.name})),this.swatches(t,this.choiceBar),this.choiceBar.append(Et("button",{class:"o-btn",text:"\xD7",title:"Close",onclick:()=>{this.choiceBar.hidden=!0}})),this.choiceBar.hidden=!1}buildMarkers(){for(let t of this.app.data.hotspots||[]){let e=Et("button",{class:"o-marker",title:t.title||t.name,onclick:n=>{n.stopPropagation(),this.openSpot(t)}},Et("span",{text:t.view&&!t.text&&!t.image&&!t.video&&!t.url?"\u279C":"i"}));this.markerLayer.append(e),this.markers.push({h:t,el:e,p:new R(...t.position),seen:!0})}}openSpot(t){let e=this.app,n=e.data.views||[],i=t.view?n.findIndex(a=>a.name===t.view):-1;if(i>=0&&!t.text&&!t.image&&!t.video&&!t.url){e.nav.goToView(i);return}let r=this.panels.spot,o=t.video&&/\.(mp4|webm|ogv)(\?|$)/i.test(t.video);r.replaceChildren(Et("button",{class:"o-close",text:"\xD7",title:"Close",onclick:()=>this.toggle(null)}),Et("h2",{text:t.title||t.name}),t.image?Et("img",{src:/^https?:/.test(t.image)?t.image:e.base+t.image,alt:t.title||""}):null,o?Et("video",{src:/^https?:/.test(t.video)?t.video:e.base+t.video,controls:!0,playsinline:!0,preload:"metadata"}):null,...String(t.text||"").split(/\n\s*\n/).filter(a=>a.trim()).map(a=>Et("p",{text:a.trim()})),t.video&&!o?Et("a",{class:"o-btn",href:t.video,target:"_blank",rel:"noopener",text:"Watch the film"}):null,t.url?Et("a",{class:"o-btn",href:t.url,target:"_blank",rel:"noopener",text:"Open the link"}):null,i>=0?Et("button",{class:"o-btn",text:"Go to "+t.view,onclick:()=>{this.toggle(null),e.nav.goToView(i)}}):null);for(let[a,c]of Object.entries(this.panels))c.hidden=a!=="spot";this.openHotspot=t}buildPlan(){this.planEl=Et("div",{class:"o-plan",title:"Click to go there"},this.planCanvas=Et("canvas",{width:gn,height:gn}),this.planDot=Et("i",{class:"o-plan-dot"})),this.planEl.addEventListener("click",t=>this.planClick(t)),this.root.append(this.planEl),this.planCam=new qn(-1,1,1,-1,.1,5e3),this.planTarget=new je(gn,gn),this.planFloor=null,this.planDirty=!0}planRegion(){let t=this.app.world.bounds,e=t.getSize(new R),n=t.getCenter(new R);return{cx:n.x,cz:n.z,span:Math.max(e.x,e.z,4)*1.08}}drawPlan(){let t=this.app,e=t.nav;if(t.xr.presenting||!this.planCanvas)return;let n=t.world.bounds,i=e.hover?n.min.y:e.pos.y;this.planFloor=i,this.planDirty=!1;let r=this.planRegion(),o=this.planCam;o.left=-r.span/2,o.right=r.span/2,o.top=r.span/2,o.bottom=-r.span/2,o.position.set(r.cx,n.max.y+50,r.cz),o.up.set(0,0,-1),o.lookAt(r.cx,0,r.cz),o.updateProjectionMatrix(),o.updateMatrixWorld();let a=t.renderer,c=Math.min(i+e.eyeDefault+.7,n.max.y+.01),l=t.clip.constant,h=t.scene.fog,f=t.scene.background;t.clip.constant=c,t.scene.fog=null,t.scene.background=null,a.setRenderTarget(this.planTarget),a.setClearColor(856343,1),a.clear(),a.render(t.scene,o);let u=new Uint8Array(gn*gn*4);a.readRenderTargetPixels(this.planTarget,0,0,gn,gn,u),a.setRenderTarget(null),t.clip.constant=l,t.scene.fog=h,t.scene.background=f;let d=this.planCanvas.getContext("2d"),g=d.createImageData(gn,gn),v=t.eye?t.eye.base:a.toneMappingExposure,m=new Uint8Array(256);for(let p=0;p<256;p++){let x=p/255*v;m[p]=Math.round(255*Math.pow(Math.min(x/(1+x*.35),1),1/2.2))}for(let p=0;p<gn;p++){let x=(gn-1-p)*gn*4,M=p*gn*4;for(let y=0;y<gn*4;y+=4){let S=u[x+y+3];g.data[M+y]=S?m[u[x+y]]:13,g.data[M+y+1]=S?m[u[x+y+1]]:17,g.data[M+y+2]=S?m[u[x+y+2]]:23,g.data[M+y+3]=255}}d.putImageData(g,0,0)}planClick(t){let e=this.app,n=this.planEl.getBoundingClientRect(),i=this.planRegion(),r=i.cx+((t.clientX-n.left)/n.width-.5)*i.span,o=i.cz+((t.clientY-n.top)/n.height-.5)*i.span,a=(this.planFloor??e.world.bounds.min.y)+e.nav.eyeDefault+.6,c=e.nav.floorUnder(new R(r,a,o),0,500);c!==null&&(e.nav.stopTour(),e.nav.mode!=="walk"?e.nav.enterAt(new R(r,c,o)):this.fade(()=>{e.nav.settle(new R(r,c+e.nav.eyeDefault,o))}))}measureToggle(t=!this.measure.on){if(this.measure.on=t,this.btns.measure&&this.btns.measure.classList.toggle("o-on",t),this.app.canvas.classList.toggle("o-measuring",t),t)this.toast("Click two points to measure between them");else{for(let e of this.measure.lines)this.app.scene.remove(e.line),e.label.remove();this.measure.lines=[],this.measure.points=[]}}measureClick(t){let e=this.measure;if(e.points.push(t.point.clone()),e.points.length<2)return;let[n,i]=e.points;e.points=[];let r=new ye;r.setAttribute("position",new ae([n.x,n.y,n.z,i.x,i.y,i.z],3));let o=new Un(r,new Wn({color:16765757,depthTest:!1,transparent:!0}));o.renderOrder=999,o.frustumCulled=!1,this.app.scene.add(o);let a=n.distanceTo(i),c=Et("div",{class:"o-label",text:a>=1?a.toFixed(2)+" m":Math.round(a*100)+" cm"});this.labelLayer.append(c),e.lines.push({line:o,label:c,mid:n.clone().lerp(i,.5),length:a})}key(t){let e=this.app,n=e.nav;switch(t.code){case"BracketRight":return n.goToView(n.viewIndex+1),!0;case"BracketLeft":return n.goToView(n.viewIndex<0?-1:n.viewIndex-1),!0;case"Digit1":return n.setMode("walk"),!0;case"Digit2":return n.setMode("orbit"),!0;case"Digit3":return n.setMode("top"),!0;case"KeyT":return this.tourToggle(),!0;case"KeyM":return this.btns.measure&&this.measureToggle(),!0;case"KeyF":return this.fullscreen(),!0;case"KeyH":return this.toggle("help"),!0;case"Escape":return this.toggle(null),this.choiceBar.hidden=!0,this.measure.on&&this.measureToggle(!1),!0}return!1}clicked(t){if(this.toggle(null),!t)return!1;if(this.measure.on)return this.measureClick(t),!0;let e=t.owner&&t.owner.name,n=e&&(this.app.data.choices||[]).find(i=>i.objects.includes(e)&&(this.app.world.meshes.get(e)||[])[i.slot]===t.owner.mesh);return n?(this.openChoice(n),t.normal.y<=.6):(this.choiceBar.hidden=!0,!1)}hover(){}viewChanged(t){let e=(this.app.data.views||[])[t];e&&(this.toast(e.name),history.replaceState(null,"","#view="+encodeURIComponent(e.name)))}modeChanged(t){for(let e of["walk","orbit","top"])this.btns[e].classList.toggle("o-on",e===t);this.planEl&&(this.planEl.hidden=t==="top"),t!=="walk"&&this.toast(t==="top"?"Click a floor to stand there":"Drag to turn it round. Click a floor to stand there")}tourToggle(){let t=this.app.nav;t.tour?t.stopTour():t.startTour()}tourChanged(t){this.btns&&this.btns.tour&&this.btns.tour.classList.toggle("o-on",t)}soundToggle(t){if(!this.audio)return;let e=t??this.audio.paused;e?this.audio.play().catch(()=>{}):this.audio.pause(),this.btns.sound.classList.toggle("o-on",e)}fullscreen(){document.fullscreenElement?document.exitFullscreen():document.documentElement.requestFullscreen&&document.documentElement.requestFullscreen().catch(()=>{})}copyLink(){let t=location.href.split("#")[0]+"#p="+this.app.nav.here().join(",");history.replaceState(null,"",t);let e=()=>this.toast("A link to this spot was copied");navigator.clipboard&&window.isSecureContext?navigator.clipboard.writeText(t).then(e,()=>this.toast(t)):this.toast(t),this.toggle(null)}toast(t,e=2600){this.toastEl&&(this.toastEl.textContent=t,this.toastEl.hidden=!1,clearTimeout(this.toastTimer),this.toastTimer=setTimeout(()=>{this.toastEl.hidden=!0},e))}fade(t,e){if(this.fading){t(),e&&e();return}this.fading=!0,this.fadeEl.classList.add("o-dark"),setTimeout(()=>{t(),this.app.eye&&this.app.eye.snap(),this.fadeEl.classList.remove("o-dark"),setTimeout(()=>{this.fading=!1,e&&e()},240)},240)}started(){this.coverEl.classList.add("o-gone"),setTimeout(()=>this.coverEl.remove(),500),this.audio&&this.soundToggle(!0)}update(){let t=this.app,e=t.nav;if(!this.markerLayer||t.xr.presenting)return;this.frame++;let n=t.activeCamera,i=t.canvas.clientWidth,r=t.canvas.clientHeight,o=n.getWorldPosition(new R),a=(c,l,h=60)=>{rs.copy(c).project(n);let f=rs.z>-1&&rs.z<1&&Math.abs(rs.x)<1.05&&Math.abs(rs.y)<1.05&&(e.mode!=="walk"||o.distanceTo(c)<h);return l.hidden=!f,f&&(l.style.transform=`translate(${((rs.x+1)/2*i).toFixed(1)}px, ${((1-rs.y)/2*r).toFixed(1)}px)`),f};this.markers.forEach((c,l)=>{if(a(c.p,c.el)&&e.mode==="walk"&&this.frame%Math.max(this.markers.length,1)===l){let f=o.distanceTo(c.p);c.seen=f<.3||e.cast(o,rs.copy(c.p).sub(o),f-.15)===null}c.el.classList.toggle("o-behind",e.mode==="walk"&&!c.seen)});for(let c of this.measure.lines)a(c.mid,c.label,1e9);if(this.planEl&&!this.planEl.hidden){let c=e.hover?t.world.bounds.min.y:e.pos.y;(this.planDirty||this.planFloor===null||Math.abs(c-this.planFloor)>1.2&&e.onGround&&!e.move)&&this.drawPlan();let l=this.planRegion(),h=((e.mode==="walk"?e.pos.x:e.orbit.target.x)-l.cx)/l.span+.5,f=((e.mode==="walk"?e.pos.z:e.orbit.target.z)-l.cz)/l.span+.5;this.planDot.hidden=e.mode!=="walk"||h<0||h>1||f<0||f>1,this.planDot.style.left=(h*100).toFixed(2)+"%",this.planDot.style.top=(f*100).toFixed(2)+"%",this.planDot.style.transform=`translate(-50%, -50%) rotate(${(-e.yaw).toFixed(3)}rad)`}}};var El=28,bM=7.5,TM=me.degToRad(30),na=new R,Rl=new R,Me=new R,wM=new R,Cl=class{constructor(t){this.app=t,this.presenting=!1,this.supported=!1,this.hands=[],this.aim=null,this.snapReady=!0,this.buttons={},this.panel=null,this.fadeT=0,this.moved=0}async init(){let t=this.app,e=t.data.options||{};if(!navigator.xr||e.vr===!1)return;try{this.supported=await navigator.xr.isSessionSupported("immersive-vr")}catch{this.supported=!1}if(!this.supported)return;let n=t.renderer.xr;n.enabled=!0,n.setReferenceSpaceType("local-floor"),t.ui.btns.vr.hidden=!1,n.addEventListener("sessionstart",()=>this.began()),n.addEventListener("sessionend",()=>this.ended()),this.build(),navigator.xr.addEventListener&&navigator.xr.addEventListener("sessiongranted",()=>this.enter())}build(){let t=this.app,e=t.renderer.xr,n=5809919;this.group=new Ye,this.group.visible=!1,t.rig.add(this.group);for(let r=0;r<2;r++){let o=e.getController(r),a=e.getControllerGrip(r),c={index:r,ray:o,grip:a,source:null,held:!1},l=new ye;l.setAttribute("position",new ae([0,0,0,0,0,-1],3)),c.line=new Un(l,new Wn({color:n,transparent:!0,opacity:.7})),c.line.scale.z=3,o.add(c.line);let h=new Ee(new xo(.018,.022,.12,12),new Oe({color:3159613}));h.rotation.x=-Math.PI/2.6,h.position.set(0,-.02,.03),a.add(h),o.addEventListener("connected",f=>{c.source=f.data,o.visible=a.visible=!0}),o.addEventListener("disconnected",()=>{c.source=null,o.visible=a.visible=!1}),o.addEventListener("selectstart",()=>this.pressed(c)),o.addEventListener("selectend",()=>this.released(c)),o.visible=a.visible=!1,t.rig.add(o,a),this.hands.push(c)}let i=new ye;i.setAttribute("position",new ae(new Float32Array(El*3),3)),this.arc=new Un(i,new Wn({color:n,transparent:!0,opacity:.9})),this.arc.frustumCulled=!1,this.arc.visible=!1,this.reticle=new Ee(new yo(.16,.22,32).rotateX(-Math.PI/2),new Oe({color:n,transparent:!0,opacity:.9,side:Pe,depthTest:!1})),this.reticle.renderOrder=998,this.reticle.visible=!1,t.scene.add(this.arc,this.reticle),this.blink=new Ee(new pr(.25,16,12),new Oe({color:0,side:Ne,transparent:!0,opacity:0,depthTest:!1})),this.blink.renderOrder=1e3,this.blink.visible=!1,t.camera.add(this.blink),this.spots=(t.data.hotspots||[]).map(r=>{let o=new Ee(new pr(.07,16,12),new Oe({color:n,transparent:!0,opacity:.85,blending:Ro,depthWrite:!1}));return o.position.set(...r.position),o.userData.h=r,t.scene.add(o),o.visible=!1,o})}toggle(){this.presenting?this.app.renderer.xr.getSession().end():this.enter()}async enter(){if(!(!this.supported||this.presenting))try{let t=await navigator.xr.requestSession("immersive-vr",{optionalFeatures:["local-floor","bounded-floor","hand-tracking"]});await this.app.renderer.xr.setSession(t)}catch(t){this.app.ui.toast("The headset did not start: "+(t&&t.message?t.message:t))}}began(){let t=this.app,e=t.nav;this.presenting=!0,t.renderer.xr.setFoveation(1),e.stopTour(),e.setMode("walk"),t.ui.toggle(null),t.ui.btns.vr.classList.add("o-on");for(let r of this.spots)r.visible=!0;let n=e.eyePoint(),i=e.hover?null:e.pos.y;this.wantHead={x:n.x,z:n.z,y:i,eyeY:n.y,yaw:e.yaw,frames:0},t.camera.rotation.set(0,0,0)}ended(){let t=this.app,e=t.nav;this.presenting=!1,t.ui.btns.vr.classList.remove("o-on"),this.arc.visible=this.reticle.visible=this.blink.visible=!1;for(let i of this.spots)i.visible=!1;this.closePanel();let n=t.camera.getWorldPosition(new R);t.camera.getWorldDirection(Me),e.yaw=Math.atan2(-Me.x,-Me.z),e.pitch=0,e.settle(n),e.apply(),t.resize()}headLocal(t=wM){return t.copy(this.app.camera.position)}placeHead(t,e){let n=this.app.nav;if(e!==void 0){let a=this.app.camera.quaternion;Me.set(0,0,-1).applyQuaternion(a),n.yaw=e-Math.atan2(-Me.x,-Me.z)}let i=this.headLocal(),r=Math.cos(n.yaw),o=Math.sin(n.yaw);n.pos.set(t.x-(i.x*r+i.z*o),t.y,t.z-(-i.x*o+i.z*r)),n.velY=0,n.lastSafe.copy(n.pos),n.apply()}headWorld(t=new R){let e=this.app.nav,n=this.headLocal(),i=Math.cos(e.yaw),r=Math.sin(e.yaw);return t.set(e.pos.x+n.x*i+n.z*r,e.pos.y+n.y,e.pos.z-n.x*r+n.z*i)}pressed(t){if(this.panel){this.closePanel();return}let e=this.app;t.ray.getWorldPosition(na),t.ray.getWorldDirection(Me).negate();let n=null;for(let r of this.spots){Rl.copy(r.position).sub(na);let o=Rl.dot(Me);if(o<.1||o>25)continue;Rl.addScaledVector(Me,-o).length()<.14+o*.02&&(!n||o<n.along)&&(n={along:o,h:r.userData.h})}let i=e.nav.cast(na,Me,30);if(n&&(!i||i.distance>n.along-.2)){this.openSpot(n.h);return}if(i){let r=e.world.ownerOf(i.faceIndex),o=r&&(e.data.choices||[]).find(a=>a.objects.includes(r.name)&&(e.world.meshes.get(r.name)||[])[a.slot]===r.mesh);if(o){let a=(o.chosen??-1)+1>=o.options.length?-1:(o.chosen??-1)+1;e.world.choose(o,a),e.ui.syncChoice(o),this.toast(o.name+": "+(a<0?"as designed":o.options[a].name)),this.pulse(t,.4,40);return}}t.held=!0,this.aim={hand:t,target:null}}released(t){if(t.held=!1,!this.aim||this.aim.hand!==t)return;let e=this.aim.target;this.aim=null,this.arc.visible=this.reticle.visible=!1,e&&(this.jump(()=>{this.app.nav.hover=!1,this.placeHead(e)}),this.pulse(t,.5,60))}jump(t){this.blink.visible=!0,this.blink.material.opacity=1,this.fadeT=.22,t(),this.app.eye&&this.app.eye.snap()}pulse(t,e,n){let i=t.source&&t.source.gamepad,r=i&&i.hapticActuators&&i.hapticActuators[0];r&&r.pulse&&r.pulse(e,n).catch(()=>{})}aimArc(t){let e=this.app.nav;t.ray.getWorldPosition(na),t.ray.getWorldDirection(Me).negate();let n=Me.clone().multiplyScalar(bM),i=na.clone(),r=this.arc.geometry.attributes.position,o=.05,a=null,c=0;for(let l=0;l<El&&(r.setXYZ(l,i.x,i.y,i.z),c=l+1,!a);l++){let h=i.clone().addScaledVector(n,o);n.y-=9.8*o;let f=h.clone().sub(i),u=f.length(),d=e.cast(i,f,u);if(d){d.normal.y>.6&&(a=d.point.clone()),i.copy(d.point),r.setXYZ(Math.min(l+1,El-1),i.x,i.y,i.z),c=Math.min(l+2,El);break}i.copy(h)}return r.needsUpdate=!0,this.arc.geometry.setDrawRange(0,c),a}textPlane(t,e,n=.9){let o=document.createElement("canvas"),a=o.getContext("2d"),c=(v,m,p)=>{a.font=m;let x=[];for(let M of String(v).split(`
`)){let y="";for(let S of M.split(/\s+/)){let T=y?y+" "+S:S;a.measureText(T).width>p&&y?(x.push(y),y=S):y=T}x.push(y)}return x},l='600 54px "JetBrains Mono", ui-monospace, monospace',h='36px "JetBrains Mono", ui-monospace, monospace',f=t?c(t,l,928):[],u=e?c(e,h,928).slice(0,14):[];o.width=1024,o.height=96+f.length*68+(u.length?20+u.length*50:0),a.fillStyle="rgba(13, 17, 23, 0.92)",a.fillRect(0,0,1024,o.height),a.strokeStyle="#30363d",a.lineWidth=4,a.strokeRect(2,2,1020,o.height-4),a.textBaseline="top",a.fillStyle="#f0f6fc",a.font=l,f.forEach((v,m)=>a.fillText(v,48,48+m*68)),a.fillStyle="#c9d1d9",a.font=h,u.forEach((v,m)=>a.fillText(v,48,48+f.length*68+20+m*50));let d=new Ai(o);d.colorSpace=ee;let g=new Ee(new Ri(n,n*o.height/1024),new Oe({map:d,transparent:!0,depthTest:!1,toneMapped:!1}));return g.renderOrder=999,g}show(t,e,n){let i=this.app,r=i.camera.getWorldPosition(new R);return i.camera.getWorldDirection(Me),Me.y=0,Me.lengthSq()<1e-4&&Me.set(0,0,-1),Me.normalize(),t.position.copy(r).addScaledVector(Me,e),t.position.y=r.y-.1,t.lookAt(r.x,t.position.y,r.z),i.scene.add(t),t.userData.left=n,t}drop(t){t&&(this.app.scene.remove(t),t.material.map.dispose(),t.material.dispose(),t.geometry.dispose())}openSpot(t){let e=this.app,n=e.data.views||[],i=t.view?n.findIndex(r=>r.name===t.view):-1;if(i>=0&&!t.text&&!t.image){this.jump(()=>e.nav.goToView(i,{instant:!0}));return}this.closePanel(),this.panel=this.show(this.textPlane(t.title||t.name,t.text||""),1.3,1/0)}closePanel(){this.drop(this.panel),this.panel=null}toast(t){this.drop(this.note),this.note=this.show(this.textPlane(t,"",.6),1.6,2.2)}update(t){if(!this.presenting)return;let e=this.app,n=e.nav;if(this.wantHead&&this.wantHead.frames++>=2){let u=this.wantHead;this.wantHead=null;let d=this.headLocal();u.y===null?(n.hover=!0,this.placeHead(new R(u.x,u.eyeY-d.y,u.z),u.yaw)):this.placeHead(new R(u.x,u.y,u.z),u.yaw)}this.fadeT>0&&(this.fadeT-=t,this.blink.material.opacity=me.clamp(this.fadeT/.12,0,1),this.fadeT<=0&&(this.blink.visible=!1)),this.note&&(this.note.userData.left-=t)<=0&&(this.drop(this.note),this.note=null),this.aim&&(this.aim.target=this.aimArc(this.aim.hand),this.arc.visible=!0,this.reticle.visible=!!this.aim.target,this.aim.target&&(this.reticle.position.copy(this.aim.target).y+=.02));let i=e.renderer.xr.getSession(),r=0,o=0,a=0,c={};for(let u of i?i.inputSources:[]){let d=u.gamepad;if(!d)continue;let g=d.axes.length>=4?[d.axes[2],d.axes[3]]:[d.axes[0]||0,d.axes[1]||0];u.handedness==="left"?(r=g[0],o=g[1]):(a=g[0],Math.abs(g[1])>.6&&Math.abs(g[0])<.4&&(o=g[1])),c.next=c.next||!!(d.buttons[4]&&d.buttons[4].pressed),c.prev=c.prev||!!(d.buttons[5]&&d.buttons[5].pressed)}if((e.data.views||[]).length&&(c.next&&!this.buttons.next&&this.jump(()=>n.goToView(n.viewIndex+1,{instant:!0})),c.prev&&!this.buttons.prev&&this.jump(()=>n.goToView(n.viewIndex<0?-1:n.viewIndex-1,{instant:!0}))),this.buttons=c,Math.abs(a)>.65&&this.snapReady){this.snapReady=!1;let u=this.headWorld();n.yaw-=Math.sign(a)*TM,this.placeHead(new R(u.x,n.pos.y,u.z))}else Math.abs(a)<.3&&(this.snapReady=!0);let h=new R;if(Math.hypot(r,o)>.15){e.camera.getWorldDirection(Me),Me.y=0,Me.normalize();let u=Rl.set(-Me.z,0,Me.x);h.addScaledVector(Me,-o).addScaledVector(u,r).multiplyScalar(n.speed*1.4*t)}let f=h.lengthSq()>0;if(n.hover)f&&n.pos.add(h);else if(n.bvh){let u=this.headWorld(),d=new R(u.x,n.pos.y,u.z),g=d.clone(),v=Math.max(u.y-n.pos.y,.6);h.multiplyScalar(1/5);for(let p=0;p<5;p++)n.physics(t/5,h,d,v);let m=g.clone().add(h.multiplyScalar(5));if(n.pos.add(d.clone().sub(g)),f&&m.distanceTo(d)>h.length()*.6&&(this.moved+=t,this.moved>.15)){this.moved=0;for(let p of this.hands)p.source&&p.source.handedness==="left"&&this.pulse(p,.3,30)}n.pos.y<e.world.bounds.min.y-30?n.pos.copy(n.lastSafe):n.onGround&&n.lastSafe.copy(n.pos)}else n.pos.add(h);n.apply()}};var zi=48,os=27,Pl=.3,uf=.8,Il=1.5,AM=.6,EM=8,Pm=1.6,ff=.2,RM=.9,CM=.4,Ll=class{constructor(t){this.app=t;let e=t.renderer;if(this.base=e.toneMappingExposure,this.gain=1,this.want=1,this.reference=t.world.reference||0,this.on=(t.data.options||{}).auto_exposure!==!1&&this.reference>0,this.since=Pl,this.busy=!1,this.measured=0,this.jump=!0,this.turn=0,this.waited=0,this.sync=!1,!!this.on){this.half=!0;try{this.half=e.capabilities.textureTypeReadable(cn)&&e.extensions.has("EXT_color_buffer_float")}catch{this.half=!1}this.target=new je(zi,os,{type:this.half?cn:an,depthBuffer:!0}),this.buffer=this.half?new Uint16Array(zi*os*4):new Uint8Array(zi*os*4),this.cam=new Le(70,zi/os,.05,6e3),this.cam.matrixAutoUpdate=!1}}read(){let t=this.buffer,e=this.half,n=0,i=0;for(let r=0;r<os;r++){let o=1-.6*Math.abs((r+.5)/os-.5)*2;for(let a=0;a<zi;a++){let c=(r*zi+a)*4,l=e?xs.fromHalfFloat(t[c]):t[c]/255,h=e?xs.fromHalfFloat(t[c+1]):t[c+1]/255,f=e?xs.fromHalfFloat(t[c+2]):t[c+2]/255,u=.2126*l+.7152*h+.0722*f;if(!(u>=0))continue;let d=o*(1-.6*Math.abs((a+.5)/zi-.5)*2);n+=Math.log(Math.min(u,64)+.002)*d,i+=d}}return i>0?Math.exp(n/i):0}look(){let t=this.app,e=t.renderer,n=e.xr.isPresenting?e.xr.getCamera():t.activeCamera;if(!n||n.isOrthographicCamera)return;n.updateMatrixWorld(),this.cam.matrixWorld.copy(n.matrixWorld),this.cam.matrixWorldInverse.copy(this.cam.matrixWorld).invert();let i=e.xr.enabled,r=e.getRenderTarget();e.xr.enabled=!1,e.setRenderTarget(this.target),e.clear(),e.render(t.scene,this.cam),e.setRenderTarget(r),e.xr.enabled=i,this.busy=!0,this.waited=0;let o=++this.turn,a=()=>{if(o!==this.turn)return;this.busy=!1;let c=this.read();if(!(c>0))return;this.measured=c;let l=this.reference/c,h=1;l>Il?h=Math.min(Math.pow(l/Il,uf),Math.max(1,ff/Math.max(this.base*c,1e-5))):l<1/Il&&(h=Math.pow(l*Il,uf));let f=this.base*c;f>ff*Pm&&(h=Math.min(h,Math.pow(ff*Pm/f,uf))),this.want=Math.min(Math.max(h,AM),EM)};e.readRenderTargetPixelsAsync&&!e.xr.isPresenting&&!this.sync?e.readRenderTargetPixelsAsync(this.target,0,0,zi,os,this.buffer).then(a,()=>{o===this.turn&&(this.busy=!1)}):(e.readRenderTargetPixels(this.target,0,0,zi,os,this.buffer),a())}snap(){this.jump=!0,this.since=Pl}update(t){if(!this.on)return;let e=this.app.renderer;this.since+=t,this.busy&&(this.waited+=t,this.waited>1&&(this.sync=!0,this.busy=!1,this.turn++));let n=e.xr.isPresenting||this.sync?Pl*2:Pl;if(this.since>=n&&!this.busy&&(this.since=0,this.look()),this.jump&&!this.busy&&this.measured>0)this.gain=this.want,this.jump=!1;else{let i=this.want>this.gain?RM:CM;this.gain+=(this.want-this.gain)*(1-Math.exp(-t/i))}e.toneMappingExposure=this.base*this.gain}};var df=class{constructor(){this.base="scene/",this.canvas=document.getElementById("oriel-view"),this.started=!1,this.frames=0,this.timer=new wo}async boot(){let t=new URLSearchParams(location.search);this.light=t.get("q")==="low"||t.get("q")!=="high"&&matchMedia("(pointer: coarse)").matches;try{let l=await fetch(this.base+"scene.json",{cache:"no-cache"});if(!l.ok)throw new Error(l.status+" "+l.statusText);this.data=await l.json()}catch(l){this.data={title:document.title},this.ui=new ea(this),this.ui.failed(location.protocol==="file:"?"A walkthrough has to come from a web server. On this computer: run serve.py, which is beside this page, and open the address it prints.":"The scene could not be read ("+l.message+").");return}let e=this.data;e.title&&(document.title=e.title),this.ui=new ea(this);let n;try{n=new qc({canvas:this.canvas,antialias:!0,powerPreference:"high-performance"})}catch{this.ui.failed("This browser cannot draw 3D (WebGL 2 is needed).");return}this.renderer=n,n.setPixelRatio(Math.min(window.devicePixelRatio||1,this.light?1.5:2)),n.outputColorSpace=ee,this.clip=new $e(new R(0,-1,0),1e7),n.clippingPlanes=[this.clip],this.scene=new oo;let i=e.views||[];this.camera=new Le(i.length?i[0].fov:60,1,.05,6e3),this.activeCamera=this.camera,this.rig=new Ye,this.rig.add(this.camera),this.scene.add(this.rig),this.manager=new mr;let r=0,o=0,a=this.manager.itemStart.bind(this.manager),c=this.manager.itemEnd.bind(this.manager);this.manager.itemStart=l=>{r++,a(l)},this.manager.itemEnd=l=>{r--,o++,this.ui.progress(.35+.65*o/Math.max(o+r,1),"Loading the materials\u2026"),c(l)},this.world=new wl(this),this.xr=new Cl(this),this.nav=new Al(this);try{await this.world.load(l=>this.ui.progress(l*.35,"Loading the shapes\u2026"))}catch(l){console.error(l),this.ui.failed("The scene could not be read ("+(l&&l.message?l.message:l)+").");return}await Promise.all(this.world.pending||[]),this.eye=new Ll(this);for(let l of e.choices||[])for(let h of l.options)this.world.mats.get(h.material);await new Promise(l=>{let h=()=>r<=0?l():setTimeout(h,40);h()}),this.noProbes=t.get("probes")==="0",this.ui.progress(1,"Looking round\u2026"),await this.world.reflect(),this.ui.build(),await this.xr.init(),this.place(i),window.addEventListener("resize",()=>this.resize()),this.resize(),this.shadowsChanged(),n.setAnimationLoop(()=>this.frame()),this.ui.ready(),this.ready=!0,(t.has("autostart")||t.has("embed"))&&this.start()}place(t){let e=this.nav,n=this.data.options||{},i=decodeURIComponent(location.hash.slice(1)),r=/^p=([-\d.,e]+)$/.exec(i);if(r){let c=r[1].split(",").map(Number);if(c.length>=5&&c.every(Number.isFinite)){e.yaw=c[3],e.pitch=c[4],e.settle(new R(c[0],c[1],c[2])),e.apply();return}}let o=/^view=(.+)$/.exec(i),a=t.findIndex(c=>c.name===(o?o[1]:n.start_view));if(a<0&&(a=0),t.length)e.viewIndex=a,e.placeAt(t[a]);else{let c=this.world.bounds,l=c.getCenter(new R),h=c.getSize(new R);e.yaw=0,e.pitch=-.15,e.settle(new R(l.x,c.min.y+e.eyeDefault,l.z+Math.max(h.z*.5+4,6))),e.apply()}}start(){this.started||(this.started=!0,this.nav.lastInput=performance.now(),this.ui.started(),(this.data.options||{}).auto_tour&&this.nav.startTour())}shadowsChanged(){let t=this.world&&this.world.sun;t&&t.castShadow&&(t.shadow.needsUpdate=!0)}resize(){if(this.renderer.xr.isPresenting)return;let t=window.innerWidth,e=window.innerHeight;this.renderer.setSize(t,e,!1),this.camera.aspect=t/Math.max(e,1),this.camera.updateProjectionMatrix(),this.nav.apply()}frame(){this.timer.update();let t=this.timer.getDelta();this.xr.update(t),this.nav.update(t),this.world.tick(t),this.ui.update(t),this.eye.update(t),this.renderer.render(this.scene,this.xr.presenting?this.camera:this.activeCamera),this.frames++}state(){let t=this.nav,e=this.renderer.info;return{mode:t.mode,position:t.pos.toArray(),eye:t.eye,yaw:t.yaw,pitch:t.pitch,view:t.viewIndex,hover:t.hover,onGround:t.onGround,moving:!!t.move,tour:!!t.tour,frames:this.frames,triangles:this.world.triangles,drawn:e.render.triangles,calls:e.render.calls,objects:this.world.objects.size,baked:this.world.baked,vr:this.xr.presenting,vrSupported:this.xr.supported,started:this.started,exposure:this.renderer.toneMappingExposure,light:this.eye.on?{gain:this.eye.gain,want:this.eye.want,seen:this.eye.measured,reference:this.eye.reference}:null}}},Im=new df;window.oriel=Im;Im.boot();
