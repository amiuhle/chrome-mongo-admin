/**
 * Listens for the app launching then creates the window
 *
 * @see http://developer.chrome.com/trunk/apps/experimental.app.html
 * @see http://developer.chrome.com/trunk/apps/app.window.html
 */
chrome.app.runtime.onLaunched.addListener(function(intentData) {
  console.log(intentData);
  chrome.app.window.create('index.html', {
      width: 960, //1278,
      height: 600 //771
  });
});
