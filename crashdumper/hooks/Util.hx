package crashdumper.hooks;
import crashdumper.hooks.openfl.HookOpenFL;
import haxe.Http;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.io.StringInput;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequestHeader;
import openfl.net.URLRequestMethod;
import openfl.net.URLRequest;
import openfl.net.URLVariables;


/**
 * ...
 * @author larsiusprime
 */
class Util
{
	public function new() 
	{
		throw "You can't and shouldn't instantiate this!";		
	}
	
	/**
	 * 
	 * @return
	 */
	
	public static function platform():IHookPlatform
	{
		#if openfl
			return new HookOpenFL();
		#end
	}
	
	public static function pathFix(str:String):String
	{
		str = fixSlashes(str);
		#if (haxe_ver < "3.1.0")
			return Path.removeTrailingSlashes(str);
		#end
		return str;
	}
	
	public static function fixSlashes(str:String):String
	{
		var slash:String = slash();
		
		var otherslash:String = "";
		if (slash == "/") {
			otherslash = "\\";
		}else if(slash == "\\"){
			otherslash = "/";
		}
		
		//enforce operating system slash style
		while (str.indexOf(otherslash) != -1)
		{
			str = StringTools.replace(str, otherslash, slash);
		}
		
		return str;
	}
	
	public static function sendReport(request:Http, bytes:Bytes, onCompleteCallback: String->Void = null):Void
	{
		var zipString:String = "";
		#if (haxe_ver >= "3.1.3")
			zipString = bytes.getString(0, bytes.length);
		#else
			zipString = bytes.readString(0, bytes.length);
		#end
		
		#if (!flash && !html5)
			var stringInput = new StringInput(zipString);
			request.fileTransfer("report", "report.zip", stringInput, stringInput.length, "application/octet-stream");
			request.request(true);
		#else
			var stringInput = new StringInput(zipString);

			/*var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = request.url;
			urlRequest.contentType="application/octet-stream";
			//urlRequest.contentType = "multipart/form-data; boundary=<<boundary here>>";
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = stringInput;
			
			//urlRequest.data = '{"report":' + zipString + '}';
			

			var urlLoader:URLLoader = new URLLoader();			
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, function(evt: Event): Void {
				trace((cast evt.currentTarget).data);
				trace("APA LALALA");
			});
			urlLoader.load(urlRequest);*/
			
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = request.url + "?flash=1";
			urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = UploadPostHelper.getPostData("report", bytes.getData());
			urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );

			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, function(evt: Event): Void {
				if (onCompleteCallback != null) {
					onCompleteCallback((cast evt.currentTarget).data);
				}
				trace((cast evt.currentTarget).data);
			});
			/*urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);*/
			urlLoader.load(urlRequest);			

		#end

	}



	public static function slash():String
	{
		#if windows
			return "\\";
		#elseif flash
			//On flash target this API path will always be available:
			if (flash.system.Capabilities.os.toLowerCase().indexOf("win") != -1)
			{
				return "\\";
			}
			else
			{
				return "/";
			}
		#else
			return "/";
		#end
	}
}