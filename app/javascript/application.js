// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Google Maps APIの読み込み完了時に呼び出されるコールバック関数
// グローバルスコープに即座に定義
window.initGoogleMaps = function() {
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
  const mapElement = document.getElementById("map");
  if(!mapElement) return;

  try {
    const { Map } = await google.maps.importLibrary("maps");

    // デフォルトの中心位置(東京駅)
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
const clearSeedMarkers = () => {
  defaultMarkers.forEach(defaultMarker => {
    defaultMarker.map = null;
  })
  defaultMarkers = [];
}

// 検索結果マーカーをクリア
const clearSearchedMarkers = () => {
  searchMarkers.forEach(searchMarker => {
    searchMarker.map = null;
  })
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

// 検索フォーム共通処理
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

    // クリックされたsubmitボタンを取得
    const submitter = e.submitter;
    const apiType = submitter?.dataset?.apiType;

    // FormData作成
    const formData = new FormData(form);


    const selectedLocation = formData.get("location");
    await setMapCenterToSelectedLocation(selectedLocation);
    clearSeedMarkers();
    clearSearchedMarkers();

    // API種別に応じて処理を分岐
    if (apiType == 'rakuten') {
      console.log(formData)
      await rakutenHotelSearch(formData);
    } else if (apiType == "google") {
      await googlePlacesSearch(formData);
    } else {
      await hotpepperSearch(formData);
    }
  });
});

// Google Maps API検索
const googlePlacesSearch = async (formData) => {
  console.log('=== Google Places API検索処理開始 ===');
  // FormDataを正しくURLSearchParamsに変換してapi_typeを追加
  const searchParams = new URLSearchParams();
  for (let [key, value] of formData.entries()) {
    searchParams.append(key, value);
  }
  searchParams.append('api_type', 'google');

  console.log('検索パラメータ:', searchParams.toString());
  console.log('FormDataの内容:');
  try {
    const response = await fetch(`/maps/location_search?${searchParams.toString()}`, {
      method: "GET",
      headers: { Accept: "application/json" }
    });

    if (!response.ok) throw new Error("通信に失敗しました");
    const data = await response.json();

    if (data && data.places && data.places.length > 0) {
      setSearchMarkers(data.places);
    } else {
      alert('検索結果が見つかりませんでした');
    }
  } catch (error) {
    console.error('Google Places API検索エラー:', error);
  }
}

// 楽天トラベルAPI検索
const rakutenHotelSearch = async (formData) => {
  console.log('=== 楽天トラベルAPI検索処理開始 ===');
  // FormDataをコピーしてapi_typeを追加
  const searchParams = new URLSearchParams();
  // formDataにparamsを含める処理
  for (let [key, value] of formData.entries()) {
    searchParams.append(key, value);
  }
  searchParams.append('api_type', 'rakuten');

  try {
    const response = await fetch(`/maps/location_search?${searchParams.toString()}`, {
      method: "GET",
      headers: { Accept: "application/json" }
    });
    if (!response.ok) throw new Error("通信に失敗しました");
    const data = await response.json();
    // 楽天API用のマーカー処理
    setRakutenMarkers(data.hotels || []);
  } catch (error) {
    alert('見つかりませんでした');
  }
}

// hot pepper API検索
const hotpepperSearch = async(formData) => {
  console.log('=== hot pepper検索処理開始 ===')
  const searchParams = new URLSearchParams();
  for (let [key, value] of formData.entries()) {
    searchParams.append(key, value);
  }
  searchParams.append('api_type', 'hotpepper');

  try {
    const response = await fetch(`/maps/location_search?${searchParams.toString()}`,{
      method: "GET",
      headers: { Accept: "application/json"}
    });
    if (!response.ok) throw new Error("通信に失敗しました");
    const data = await response.json();
  }catch(error){
    alert('見つかりませんでした');
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
          ${window.currentUserLoggedIn
            ? `<button id="add_itinerary_button"
                        data-place-id="${hotel.hotel?.[0]?.hotelBasicInfo?.hotelNo || ''}"
                        data-name="${name}"
                        data-lat="${lat}"
                        data-lng="${lng}"
                        class="mt-2 px-3 py-1 bg-red-400 text-white rounded-xs hover:bg-red-500">
              +旅程追加!
            </button>`
            : ''
          }
        `);
        infoWindow.open(window.map, rakutenMarker);
        // 情報ウィンドウが開かれた後にボタンのイベントリスナーを追加
        if (window.currentUserLoggedIn) {
          setTimeout(() => {
            const button = document.getElementById('add_itinerary_button');
            if (button) {
              button.addEventListener('click', handleAddItineraryClick);
            }
          }, 100);
        }
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

      // 情報ウィンドウが開かれた後にボタンのイベントリスナーを追加
      if (window.currentUserLoggedIn) {
        setTimeout(() => {
          const button = document.getElementById('add_itinerary_button');
          if (button) {
            button.addEventListener('click', handleAddItineraryClick);
          }
        }, 100);
      }
    });

    searchMarkers.push(searchMarker);
  });
}

// 旅程追加ボタンクリック処理関数
const handleAddItineraryClick = async (e) => {
  const addItineraryButton = e.target.closest('#add_itinerary_button');
  if (!addItineraryButton) return;

  e.preventDefault();
  if (addItineraryButton.disabled) return;

  const sidebar = document.getElementById('sidebar');
  if (!sidebar) return;

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

// 旅程追加ボタンを押したときの処理（既存のイベントデリゲーション保持）
document.addEventListener('turbo:load', () => {
  const sidebar = document.getElementById('sidebar');
  if (!sidebar) return;

  const clickHandler = async (e) => {
    await handleAddItineraryClick(e);
  };

  // 多重登録を防ぐため、一度外してから付け直す
  document.removeEventListener('click', clickHandler);
  document.addEventListener('click', clickHandler);
});