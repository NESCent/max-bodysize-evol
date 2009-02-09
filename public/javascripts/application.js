// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function getLeft(elem)
{
	var xPos = elem.offsetLeft;
	var tempEl = elem.offsetParent;
  	while (tempEl != null && (tempEl.style==null || tempEl.style.position!="absolute")) {
  		xPos += tempEl.offsetLeft;
		tempEl = tempEl.offsetParent;
  	}
	return xPos;
}

function getTop(elem)
{
  
  var yPos = elem.offsetTop;
  var tempEl = elem.offsetParent;
  while (tempEl != null  &&  (tempEl.style==null || tempEl.style.position!="absolute")) {
  	yPos += tempEl.offsetTop;
	tempEl = tempEl.offsetParent;
  }
  return yPos;

}