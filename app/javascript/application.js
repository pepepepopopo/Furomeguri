// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// ドロップダウンの処理（turbo:load の外で一度だけ定義）
document.addEventListener('click', (e) => {
  const isDropdownButton = e.target.closest('.dropdown-button');
  const isMenuItem = e.target.closest('.dropdown-menu button');

  // 全てのドロップダウンメニューを一度閉じる
  document.querySelectorAll('.dropdown-menu').forEach(menu => {
    menu.classList.add('hidden');
  });

  if (isDropdownButton) {
    const container = isDropdownButton.closest('.dropdown-container');
    const menu = container.querySelector('.dropdown-menu');
    if (menu) menu.classList.toggle('hidden');
  } else if (isMenuItem) {
    const container = e.target.closest('.dropdown-container');
    const button = container.querySelector('.dropdown-button');
    const menu = container.querySelector('.dropdown-menu');

    const selectedValue = e.target.textContent.trim();
    const targetInputId = button.dataset.target;
    const hiddenInput = document.getElementById(targetInputId);

    button.textContent = selectedValue;
    button.setAttribute('data-value', selectedValue);
    if (hiddenInput) hiddenInput.value = selectedValue;

    if (menu) menu.classList.add('hidden');
  }
});

// turbo:load で一度だけ初期化したい処理（地図）
document.addEventListener('turbo:load', () => {
  if (typeof initMap === 'function') {
    initMap();
  }
});

// fetchDefaultLocations の定義（load毎での重複防止）
if (!window.fetchDefaultLocations) {
  window.fetchDefaultLocations = async () => {
    const response = await fetch("/api/default_locations");
    const data = await response.json();
    return data.map(default_location => ({
      name: default_location.name,
      lat: default_location.lat,
      lng: default_location.lng,
    }));
  };
}

// Google Maps 初期化
if (!window.initMap) {
  window.initMap = async function () {
    const mapDev = document.getElementById("map");
    if(!mapDev) return;
    const { Map } = await google.maps.importLibrary("maps");

    // デフォルトの中心位置(東京駅)
    const mapElement = document.getElementById("map");
    window.map = new Map(mapElement, {
      center: { lat: 35.68125718370711, lng: 139.7665076889907 },
      zoom: 6,
      mapId: 'af2da9c1c44ffaf9d071b583',
    })

    await setDefaultMarker();
  };
}

let defaultMarkers = [];
// seed値の場所にピンを打つ
async function setDefaultMarker () {
  const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
  const locations = await fetchDefaultLocations();
  locations.forEach(location => {
    const pinCustom = new PinElement({ glyphColor: 'white' });
    const defaultMarker = new AdvancedMarkerElement({
      map: map,
      position: { lat: location.lat, lng: location.lng },
      content: pinCustom.element,
    });
    defaultMarkers.push(defaultMarker)
  });
}

// Seedマーカーをクリア
const clearMarkers = () => {
  defaultMarkers.forEach(defaultMarker => {
    defaultMarker.map = null;
  })
  defaultMarkers = [];
}

// 選択されたlocationを中心にマップを調整
async function setMapCenterToSelectedLocation(selectedLocationName) {
  const locations = await fetchDefaultLocations();
  const base = locations.find(loc => loc.name === selectedLocationName);
  if (base) {
    window.map.setCenter({ lat: base.lat, lng: base.lng });
    window.map.setZoom(16);
  }
}

let searchMarkers = [];

// テキスト検索
document.addEventListener('turbo:load', () => {
  const form = document.getElementById('location-search-form');
  if(!form) return;
  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    // 必須チェック
    const location = document.getElementById('location').value;
    if (!location) {
      alert('温泉地の選択は必須です');
      return;
    }

    // FormData→URLパラメータ化
    const formData = new FormData(form);
    const textQueryParams = new URLSearchParams(formData).toString();
    const selectedLocation = formData.get("location");
    await setMapCenterToSelectedLocation(selectedLocation);
    clearMarkers();

    try {
      const response = await fetch(`/maps/location_search?${textQueryParams}`, {
        method: "GET",
        headers: { Accept: "application/json" }
      });
      if (!response.ok) throw new Error("通信に失敗しました");
      const data = await response.json();
      // マーカーを作成
      setSearchMarkers(data.places)
    } catch (error) {
    }
  });
});
// マーカー作成(情報ウィンドウ付き)
async function setSearchMarkers(places) {
  if (!window.map) return;

  const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary('marker');
  const infoWindow = new google.maps.InfoWindow();

  places.forEach(place => {
    const { latitude: lat, longitude: lng } = place.location;
    const name = place.displayName?.text || '名称未設定';

    const searchMarker = new AdvancedMarkerElement({
      map: window.map,
      position: { lat, lng },
      title: name,
      content: new PinElement().element
    });

    // クリックされたときの情報ウィンドウ
    searchMarker.addListener('gmp-click', () => {
      infoWindow.setContent(`
        <strong>${name}</strong><br>
        ${window.currentUserLoggedIn
          ? `<button id="add_itinerary_button"
                      data-place-id="${place.id}"
                      data-name="${place.displayName.text}"
                      data-lat="${place.location.latitude}"
                      data-lng="${place.location.longitude}"
                      class="mt-2 px-3 py-1 bg-orange-400 text-white rounded hover:bg-orange-500">
            +旅程追加!
          </button>`
          : ''
        }
      `);
      infoWindow.open(window.map, searchMarker);
    });

    searchMarkers.push(searchMarker);
  });
}

// 旅程追加ボタンを押したときの処理
document.addEventListener('turbo:load', () => {
  const sidebar = document.getElementById('sidebar');
  if (!sidebar) return;

  const clickHandler = async (e) => {
    const addItineraryButton = e.target.closest('#add_itinerary_button');
    if (!addItineraryButton) return;

    e.preventDefault();
    if (addItineraryButton.disabled) return;

    const {
      placeId,
      name,
      lat: latStr,
      lng: lngStr,
    } = addItineraryButton.dataset;

    const lat = parseFloat(latStr);
    const lng = parseFloat(lngStr);
    const itineraryId = sidebar.dataset.itineraryId;

    try {
      addItineraryButton.disabled = true;

      const response = await fetch(`/itineraries/${itineraryId}/itinerary_blocks`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
        },
        body: JSON.stringify({
          itinerary_block: {
            google_place_id: placeId,
            name,
            lat,
            lng,
          },
        }),
      });
      if (response.ok) {
        const streamHtml = await response.text();
        Turbo.renderStreamMessage(streamHtml);
      } else {
      }
    } catch (error) {
      addItineraryButton.disabled = false;
    }
  };

  // 多重登録を防ぐため、一度外してから付け直す
  document.removeEventListener('click', clickHandler);
  document.addEventListener('click', clickHandler);
});
