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
    const { Map } = await google.maps.importLibrary("maps");
    const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
    const mapDiv = document.getElementById("mapDiv")
  if (!mapDiv) { // 地図が無いページなら何もしない
    return;
  }

    // デフォルトの中心位置(東京駅)
    const mapElement = document.getElementById("map");
    window.map = new Map(mapElement, {
      center: { lat: 35.68125718370711, lng: 139.7665076889907 },
      zoom: 6,
      mapId: 'af2da9c1c44ffaf9d071b583',
    })

    // seed値の場所にピンを打つ
    const locations = await fetchDefaultLocations();
    locations.forEach(location => {
      const pinCustom = new PinElement({ glyphColor: 'white' });
      new AdvancedMarkerElement({
        map: map,
        position: { lat: location.lat, lng: location.lng },
        content: pinCustom.element,
      });
    });
  };
}

// 既存検索結果マーカーをクリア
const clearSearchMarkers = () => {
  searchMarkers.forEach(m => (m.map = null));
  searchMarkers = [];
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
  if (!form) return;

  // 古いイベントリスナが複数つかないように remove→add（必要なら）
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
    console.log("fetch url: ", `/maps/location_search?${textQueryParams}`);
    const selectedLocation = formData.get("location");
    await setMapCenterToSelectedLocation(selectedLocation);

    try {
      const response = await fetch(`/maps/location_search?${textQueryParams}`, {
        method: "GET",
        headers: { Accept: "application/json" }
      });
      if (!response.ok) throw new Error("通信に失敗しました");
      const data = await response.json();
      console.log("検索結果:", data);
      setSearchMarkers(data.places)
    } catch (error) {
      console.error("Fetch エラー:", error);
    }
  });
});
// マーカー設置(情報ウィンドウ付き)
async function setSearchMarkers(places) {
  clearSearchMarkers();
  if (!window.map) return;

  const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary('marker');
  const infoWindow = new google.maps.InfoWindow();

  places.forEach(place => {
    const { latitude: lat, longitude: lng } = place.location;
    const name = place.displayName?.text || '名称未設定';

    const marker = new AdvancedMarkerElement({
      map: window.map,
      position: { lat, lng },
      title: name,
      content: new PinElement().element
    });

    // クリックイベント
    marker.addListener('gmp-click', () => {
      infoWindow.setContent(`<strong>${name}</strong>`);
      infoWindow.open(window.map, marker);
    });

    searchMarkers.push(marker);
  });
}
