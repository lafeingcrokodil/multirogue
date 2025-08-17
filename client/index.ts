import { createApp, ref } from "vue";

interface ServerEvent {
  name: string;
  data: string;
};

interface DisplayEvent {
  c: string;
  x: number;
  y: number;
};

interface LevelEvent {
  map: string;
};

interface NotificationEvent {
  msg: string;
};

interface StatsEvent {
  mapLvl: number;
  gold: number;
  hp: number;
  maxHp: number;
  str: number;
  maxStr: number;
  arm: number;
  lvl: number;
  exp: number;
};

createApp({
  setup() {
    const joined = ref(false); // true if we have joined the game
    const name = ref(""); // name of our adventurer
    const notifications = ref<string[]>([]); // notifications to be displayed above the map
    const map = ref<string[][]>([]); // lines of characters displayed on the screen
    const stats = ref(""); // player stats to be displayed below the map

    let ws: WebSocket | null = null;

    const toLine = (str: string): string => {
      const firstMapLine = map.value[0];
      if (!firstMapLine) {
        throw new RangeError("Map is empty");
      }
      return toPaddedString(str, firstMapLine.length);
    };

    const display = (event: DisplayEvent) => {
      const line = map.value[event.y]; // in the yth line...
      if (!line) {
        throw new RangeError("Y coordinate out of range: " + event.y);
      }
      line.splice(event.x, 1, event.c); // replace the xth character with c
      map.value[event.y] = line;
    };

    const displayLevel = (event: LevelEvent) => {
      const newMap: string[][] = [];
      let line: string[] = [];
      let c: string;
      for (let i = 0; i < event.map.length; i++) {
        c = event.map.charAt(i);
        if (c === "\n") {
          newMap.push(line);
          line = [];
        } else {
          line.push(c);
        }
      }
      map.value = newMap;
    }

    const displayNotification = (event: NotificationEvent) => {
      const prevMsg = notifications.value.pop();
      if (prevMsg) {
        notifications.value.push(toLine(prevMsg.trim() + "--More--"));
      }
      notifications.value.push(toLine(event.msg));
    };

    const displayStats = (event: StatsEvent) => {
      // Construct stat string.
      let statStr = "";
      statStr += "Level: " + toPaddedString(`${event.mapLvl}`, 3);
      statStr += "Gold: " + toPaddedString(`${event.gold}`, 7);
      statStr += "Hp: " + toPaddedString(`${event.hp}(${event.maxHp})`, 8);
      statStr += "Str: " + toPaddedString(`${event.str}(${event.maxStr})`, 8);
      statStr += "Arm: " + toPaddedString(`${event.arm}`, 4);
      statStr += `Exp: ${event.lvl}/${event.exp}`;

      // Publish updated stats.
      stats.value = toLine(statStr);
    };

    const fireEvent = (name: string, data: any) => {
      if (!ws) {
        throw new Error("Not connected to server");
      }
      ws.send(JSON.stringify({
        name: name,
        data: JSON.stringify(data)
      }));
    };

    const handleEvent = (messageEvent: MessageEvent) => {
      const events: ServerEvent[] = JSON.parse(messageEvent.data);
      for (const e of events) {
        switch (e.name) {
          case "display":
            display(JSON.parse(e.data));
            break;
          case "level":
            displayLevel(JSON.parse(e.data));
            break;
          case "notification":
            displayNotification(JSON.parse(e.data));
            break;
          case "stats":
            displayStats(JSON.parse(e.data));
            break;
          default:
            throw new Error("Unknown event: " + e.name);
        }
      }
    };

    const handleKeydown = (event: KeyboardEvent) => {
      switch (event.key) {
        case 'ArrowLeft':
        case 'h':
        case '4':
          fireEvent('move', { dx: -1, dy: 0 });
          break;
        case 'ArrowRight':
        case 'l':
        case '6':
          fireEvent('move', { dx: 1, dy: 0 });
          break;
        case 'ArrowUp':
        case 'k':
        case '8':
          fireEvent('move', { dx: 0, dy: -1 });
          break;
        case 'ArrowDown':
        case 'j':
        case '2':
          fireEvent('move', { dx: 0, dy: 1 });
          break;
        case 'Home':
        case 'y':
        case '7':
          fireEvent('move', { dx: -1, dy: -1 });
          break;
        case 'PageUp':
        case 'u':
        case '9':
          fireEvent('move', { dx: 1, dy: -1 });
          break;
        case 'End':
        case 'b':
        case '1':
          fireEvent('move', { dx: -1, dy: 1 });
          break;
        case 'PageDown':
        case 'n':
        case '3':
          fireEvent('move', { dx: 1, dy: 1 });
          break;
        case 'Clear':
        case '.':
        case '5':
          fireEvent('move', { dx: 0, dy: 0 });
          break;
        case '>':
          fireEvent('move', { dlvl: 1 });
          break;
        case ' ':
          notifications.value.shift();
          break;
        default:
          console.error('unsupported key press:', event.key);
          return; // don't prevent default for unrecognized keys
      }
      event.preventDefault();
    };

    const join = () => {
      if (!name.value.trim()) {
        alert("Please enter a name between 1 and 16 characters.");
        return;
      }

      ws = new WebSocket("ws://" + window.location.host + "/ws?name=" + name.value);

      ws.onopen = () => {
        console.log("Connected to server");
        joined.value = true;
      };

      ws.onmessage = handleEvent;

      ws.onclose = () => {
        console.log("Disconnected from server");
        joined.value = false;
      };

      ws.onerror = (err) => {
        throw new Error("Websocket error: " + err);
      };

      document.addEventListener("keydown", handleKeydown);
    };

    return { joined, name, notifications, map, stats, join };
  }
}).mount("#app");

// Pads the string representation of a value to the desired length by adding
// spaces to the end of it.
function toPaddedString(unpaddedStr: string, len: number): string {
  let str = `${unpaddedStr}`;
  let currLen = str.length;
  for (let i = 0; i < len - currLen; i++) {
    str += "\u00A0"; // non-breaking space (more importantly, non-collapsing)
  }
  return str
}
