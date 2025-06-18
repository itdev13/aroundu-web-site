///
/// Enum containing predefined asset paths for icons used in Design System
///
enum DesignIcons {
  logo("assets/icons/logo.svg"),
  home("assets/icons/home.svg"),
  chats("assets/icons/chats.svg"),
  profile("assets/icons/profile.svg"),
  notifications("assets/icons/notifications.svg"),
  search("assets/icons/search.svg"),
  calendar("assets/icons/calendar.svg"),
  clock("assets/icons/clock.svg"),
  levelUp("assets/icons/levelUp.svg"),
  groups("assets/icons/groups.svg"),
  heart("assets/icons/heart.svg"),
  edit("assets/icons/edit.svg"),
  google("assets/icons/google.svg"),
  camera("assets/icons/camera.svg"),
  form("assets/icons/form.svg"),
  all("assets/icons/all.svg"),
  day("assets/icons/day.svg"),
  night("assets/icons/night.svg"),
  morning("assets/icons/morning.svg"),
  evening("assets/icons/evening.svg"),
  rocket("assets/icons/rocket.svg"),
  cake("assets/icons/cake.svg"),
  location("assets/icons/location.svg"),
  face("assets/icons/face.svg"),
  cocktail("assets/icons/cocktail.svg"),
  smoking("assets/icons/smoking.svg"),
  veggies("assets/icons/veggies.svg"),
  wifi("assets/icons/wifi.svg"),
  music("assets/icons/music.svg"),
  gameController("assets/icons/gameController.svg"),
  dressFemale("assets/icons/dressFemale.svg"),
  dog("assets/icons/dog.svg"),
  money("assets/icons/money.svg"),
  match("assets/icons/match.svg"),
  //new ones
  pencil("assets/icons/pencil.svg"),
  disabled("assets/icons/disabled.svg"),
  delete("assets/icons/delete.svg"),
  personAdd("assets/icons/personAdd.svg"),
  shopAdd("assets/icons/shopAdd.svg"),
  qr("assets/icons/qr.svg"),
  question("assets/icons/question.svg"),
  respect("assets/icons/respect.svg"),
  doorOut("assets/icons/doorOut.svg"),
  thumbClock("assets/icons/thumbClock.svg"),
  law("assets/icons/law.svg"),
  upcoming("assets/icons/upcoming.svg"),
  closed("assets/icons/closed.svg"),
  past("assets/icons/past.svg"),
  chat("assets/icons/chat.svg"),
  googleMaps("assets/icons/googleMaps.svg"),
  qrSuccess("assets/icons/qrSuccess.svg"),
  contactCalendar("assets/icons/contactCalendar.svg"),
  slot("assets/icons/slot.svg"),
  importantDevices("assets/icons/importantDevices.svg"),
  tickUser("assets/icons/tickUser.svg"),
  payment("assets/icons/payment.svg"),
  star("assets/icons/star.svg"),
  running("assets/icons/running.svg"),
  localAtm("assets/icons/localAtm.svg");

  final String path;

  const DesignIcons(this.path);

  static DesignIcons? getIconFromString(String iconName) {
    try {
      // Convert the input string to lowercase and try to find matching enum value
      return DesignIcons.values.firstWhere(
        (icon) => icon.name.toLowerCase() == iconName.toLowerCase(),
      );
    } catch (e) {
      // Return null if no matching icon is found
      return null;
    }
  }
}
