package crashdumper.hooks;

import flash.events.*;
import flash.net.*;
import flash.utils.ByteArray;
import flash.utils.Endian;
import openfl.utils.Object;

/**
 * Take a fileName, byteArray, and parameters object as input and return ByteArray post data suitable for a UrlRequest as output
 *
 * @see http://marstonstudio.com/?p=36
 * @see http://www.w3.org/TR/html4/interact/forms.html
 * @see http://www.jooce.com/blog/?p=143
 * @see http://www.jooce.com/blog/wp%2Dcontent/uploads/2007/06/uploadFile.txt
 * @see http://blog.je2050.de/2006/05/01/save-bytearray-to-file-with-php/
 *
 * @author Jonathan Marston
 * @version 2007.08.19
 *
 * This work is licensed under a Creative Commons Attribution NonCommercial ShareAlike 3.0 License.
 * @see http://creativecommons.org/licenses/by-nc-sa/3.0/
 *
 */
 
class UploadPostHelper 
{

	/**
	 * Boundary used to break up different parts of the http POST body
	 */
	private static var _boundary:String = "";

	/**
	 * Get the boundary for the post.
	 * Must be passed as part of the contentType of the UrlRequest
	 */
	public static function getBoundary():String {

		if(_boundary.length == 0) {
			for (i in 0...0x20) {
				_boundary += String.fromCharCode( Std.int( 97 + Math.random() * 25 ) );
			}
		}

		return _boundary;		
	}

	/**
	 * Create post data to send in a UrlRequest
	 */
	public static function getPostData(fileName:String, byteArray:ByteArray, parameters:Object = null):ByteArray {

		var i: Int;
		var bytes:String;

		var postData:ByteArray = new ByteArray();
		postData.endian = Endian.BIG_ENDIAN;

		//add Filename to parameters
		if(parameters == null) {
			parameters = new Object();
		}
		parameters.Filename = fileName;

		//add parameters to postData
		for(name in parameters) {
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="' + name + '"';
			for ( i  in 0...bytes.length) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			postData.writeUTFBytes(parameters[name]);
			postData = LINEBREAK(postData);
		}

		//add Filedata to postData
		postData = BOUNDARY(postData);
		postData = LINEBREAK(postData);
		bytes = 'Content-Disposition: form-data; name="Filedata"; filename="';
		for ( i in 0...bytes.length) {
			postData.writeByte( bytes.charCodeAt(i) );
		}
		postData.writeUTFBytes(fileName);
		postData = QUOTATIONMARK(postData);
		postData = LINEBREAK(postData);
		bytes = 'Content-Type: application/octet-stream';
		for ( i in 0...bytes.length) {
			postData.writeByte( bytes.charCodeAt(i) );
		}
		postData = LINEBREAK(postData);
		postData = LINEBREAK(postData);
		postData.writeBytes(byteArray, 0, byteArray.length);
		postData = LINEBREAK(postData);

		//add upload filed to postData
		postData = LINEBREAK(postData);
		postData = BOUNDARY(postData);
		postData = LINEBREAK(postData);
		bytes = 'Content-Disposition: form-data; name="Upload"';
		for ( i in 0...bytes.length) {
			postData.writeByte( bytes.charCodeAt(i) );
		}
		postData = LINEBREAK(postData);
		postData = LINEBREAK(postData);
		bytes = 'Submit Query';
		for ( i in 0...bytes.length) {
			postData.writeByte( bytes.charCodeAt(i) );
		}
		postData = LINEBREAK(postData);

		//closing boundary
		postData = BOUNDARY(postData);
		postData = DOUBLEDASH(postData);

		return postData;
	}

	/**
	 * Add a boundary to the PostData with leading doubledash
	 */
	private static function BOUNDARY(p:ByteArray):ByteArray {
		var l:Int = UploadPostHelper.getBoundary().length;

		p = DOUBLEDASH(p);
		for (i in 0...l) {
			p.writeByte( _boundary.charCodeAt( i ) );
		}
		return p;
	}

	/**
	 * Add one linebreak
	 */
	private static function LINEBREAK(p:ByteArray):ByteArray {
		p.writeShort(0x0d0a);
		return p;
	}

	/**
	 * Add quotation mark
	 */
	private static function QUOTATIONMARK(p:ByteArray):ByteArray {
		p.writeByte(0x22);
		return p;
	}

	/**
	 * Add Double Dash
	 */
	private static function DOUBLEDASH(p:ByteArray):ByteArray {
		p.writeShort(0x2d2d);
		return p;
	}
	
}
