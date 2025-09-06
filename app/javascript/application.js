// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Google Maps APIの読み込み完了時に呼び出されるコールバック関数
// グローバルスコープに即座に定義
window.initGoogleMaps = function() {
  console.log('initGoogleMaps called');
  if (document.getElementById("map")) {
    initMap();
  }
};

// turbo:load で地図の再初期化
document.addEventListener('turbo:load', () => {
  if (typeof google !== 'undefined' && typeof initMap === 'function' && document.getElementById("map")) {
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

// Google Maps 初期化 - グローバルスコープで定義
window.initMap = async function () {
  if(!mapDev) return;

  try {
    const { Map } = await google.maps.importLibrary("maps");

    // デフォルトの中心位置(東京駅)
    const mapElement = document.getElementById("map");
    window.map = new Map(mapElement, {
      center: { lat: 35.68125718370711, lng: 139.7665076889907 },
      zoom: 6,
      mapId: 'af2da9c1c44ffaf9d071b583',
    })

    await setDefaultMarker();
  } catch (error) {
    console.error('Error initializing map:', error);
  }
};

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

// 検索フォーム共通処理
document.addEventListener('turbo:load', () => {
  console.log('=== turbo:load イベント発火 ===');
  const form = document.getElementById('location-search-form');
  if(!form) {
    console.log('フォームが見つかりません');
    return;
  }
  form.addEventListener('submit', async (e) => {
    console.log('=== フォーム送信イベント発火 ===');
    e.preventDefault();

    // 必須チェック
    const location = document.getElementById('location').value;
    if (!location) {
      alert('温泉地の選択は必須です');
      return;
    }

    // クリックされたsubmitボタンを取得
    const submitter = e.submitter;
    const apiType = submitter?.dataset?.apiType;
    console.log('=== 検索処理開始 ===');
    console.log('submitter:', submitter);
    console.log('apiType:', apiType);
    console.log('submitter.dataset:', submitter?.dataset);

    // FormData作成
    const formData = new FormData(form);
    const selectedLocation = formData.get("location");
    console.log('FormData contents:');
    for (let [key, value] of formData.entries()) {
      console.log(`${key}: ${value}`);
    }
    await setMapCenterToSelectedLocation(selectedLocation);
    clearMarkers();

    // API種別に応じて処理を分岐
    if (apiType === 'rakuten') {
      console.log('楽天API検索を実行');
      await rakutenHotelSearch(formData);
    } else {
      console.log('Google Places API検索を実行');
      await googlePlacesSearch(formData);
    }
  });
});

// Google Maps API検索
const googlePlacesSearch = async (formData) => {
  console.log('=== Google Places API検索処理開始 ===');
  const textQueryParams = new URLSearchParams(formData).toString();
  console.log('params:', textQueryParams);
  try {
    const response = await fetch(`/maps/location_search?${textQueryParams}`, {
      method: "GET",
      headers: { Accept: "application/json" }
    });
    if (!response.ok) throw new Error("通信に失敗しました");
    const data = await response.json();
    console.log('Google API response:', data);
    // マーカーを作成
    setSearchMarkers(data.places)
  } catch (error) {
    console.error('Google Places API検索エラー:', error);
  }
}

// 楽天トラベルAPI検索
const rakutenHotelSearch = async (formData) => {
  console.log('=== 楽天トラベルAPI検索処理開始 ===');
  // FormDataをコピーしてapi_typeを追加
  const searchParams = new URLSearchParams();
  for (let [key, value] of formData.entries()) {
    console.log(`Adding to searchParams: ${key} = ${value}`);
    searchParams.append(key, value);
  }
  searchParams.append('api_type', 'rakuten');
  console.log('Final params string:', searchParams.toString());
  console.log('URL will be:', `/maps/location_search?${searchParams.toString()}`);

  try {
    const response = await fetch(`/maps/location_search?${searchParams.toString()}`, {
      method: "GET",
      headers: { Accept: "application/json" }
    });
    if (!response.ok) throw new Error("通信に失敗しました");
    const data = await response.json();
    console.log('Rakuten API response:', data);
    // 楽天API用のマーカー処理
    setRakutenMarkers(data.hotels || []);
  } catch (error) {
    console.error('楽天トラベルAPI検索エラー:', error);
  }
}

// 楽天API用マーカー作成
async function setRakutenMarkers(hotels) {
  if (!window.map) return;

  const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary('marker');
  const infoWindow = new google.maps.InfoWindow();

  hotels.forEach(hotel => {
    const { latitude: lat, longitude: lng } = hotel.hotel?.[0]?.hotelBasicInfo || {};
    const name = hotel.hotel?.[0]?.hotelBasicInfo?.hotelName || '名称未設定';
    
    if (lat && lng) {
      const rakutenMarker = new AdvancedMarkerElement({
        map: window.map,
        position: { lat: parseFloat(lat), lng: parseFloat(lng) },
        title: name,
        content: new PinElement({ background: '#FF6B6B' }).element // 楽天用の色
      });

      // クリックされたときの情報ウィンドウ
      rakutenMarker.addListener('gmp-click', () => {
        infoWindow.setContent(`
          <strong>${name}</strong><br>
          <small>楽天トラベル</small>
        `);
        infoWindow.open(window.map, rakutenMarker);
      });

      searchMarkers.push(rakutenMarker);
    }
  });
}

// Google Places API用マーカー作成(情報ウィンドウ付き)
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
                      class="mt-2 px-3 py-1 bg-orange-400 text-white rounded-xs hover:bg-orange-500">
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