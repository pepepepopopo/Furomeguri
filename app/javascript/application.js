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

// 検索前のバリデーション(温泉地必須)
document.addEventListener('turbo:load', () => {
  const form = document.querySelector('form');
  if (form) {
    form.addEventListener('submit', function(e) {
      const location = document.getElementById('location').value;
      if (!location) {
        alert('温泉地の選択は必須です');
        e.preventDefault();
      }
    });
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

// テキスト検索
if(!window.searchLocations) {
  window.searchLocations = async (location, accommodationType, poiType, keyword) => {
    const params = new URLSearchParams({
      location: location,
      accommodation_type: accommodationType,
      poi_type: poiType,
      keyword: keyword
    });
    const response = await fetch('/maps/location_search?${prams}');
    const data = await response.json();

    if (data.status === 'success') {
      return data.places;
    } else {
      console.error('failed:', data.error);
      return [];
    }
  }
}

// Google Maps 初期化
// if (!window.initMap) {
//   window.initMap = async function () {
//     const { Map } = await google.maps.importLibrary("maps");
//     const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");

//     // デフォルトの中心位置(東京駅)
//     const map = new Map(document.getElementById("map"), {
//       center: { lat: 35.68125718370711, lng: 139.7665076889907 },
//       zoom: 6,
//       mapId: 'af2da9c1c44ffaf9d071b583',
//     });

//     // seed値の場所にピンを打つ
//     const locations = await fetchDefaultLocations();
//     locations.forEach(location => {
//       const pinCustom = new PinElement({ glyphColor: 'white' });
//       new AdvancedMarkerElement({
//         map: map,
//         position: { lat: location.lat, lng: location.lng },
//         content: pinCustom.element,
//       });
//     });

//     let searchMarkers = [];

//     // 既存検索結果マーカーをクリア
//     const clearSearchMarkers = () => {
//       searchMarkers.forEach(marker => {
//         marker.map = null;
//       });
//       searchMarkers = [];
//     }

//     // 検索結果をピンで表示
//     const setSearchMarkers = (places) => {
//       clearSearchMarkers();

//       places.forEach(place => {
//         const searchPin = new PinElement({ glyphColor: 'white' });
//         const marker = new AdvancedMarkerElement({
//           map: map,
//           position: { lat: place.lat, lng: place.lng },
//           content: pinCustom.element,
//           title: place.name
//         });

//         const infoWindow = new google.maps.InfoWindow({
//           const: `
//             <div>
//                 <h3>${place.name}</h3>
//                 <h3>${place.address}</h3>
//             </div>
//           `
//         });

//         marker.addListener('click', () => {
//           infoWindow.open(map, marker);
//         });

//         searchMarkers.push(marker);
//       });
//     };
//     // マップ表示を変更
//     const adjustMapView = (places) => {
//       map.setCenter({ lat: })
//     }
//     // フォームから呼び出してピンを設定
//     window.performSearch = async (location, accommodationType, poiType, keyword) => {
//       console.log('Performing search with:', { location, accommodationType, poiType, keyword });
//       const places = await searchLocations(location, accommodationType, poiType, keyword);
//       console.log('Search results:', places);
//       setSearchMarkers(places);
//     }

//     // 検索基準点の情報を取得する関数
//     const getBaseLocation = async (locationName) => {
//       if (!locationName) {
//         console.log('No location name provided');
//         return null;
//       }

//       const locations = await fetchDefaultLocations();
//       const foundLocation = locations.find(loc => loc.name === locationName);

//       if (foundLocation) {
//         console.log(`Found base location: ${foundLocation.name} at (${foundLocation.lat}, ${foundLocation.lng})`);
//       } else {
//         console.log(`Base location not found for: ${locationName}`);
//       }

//       return foundLocation;
//     };
//   };
// }

// Google Maps 初期化
if (!window.initMap) {
  window.initMap = async function () {
    const { Map } = await google.maps.importLibrary("maps");
    const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");

    // デフォルトの中心位置(東京駅)
    const map = new Map(document.getElementById("map"), {
      center: { lat: 35.68125718370711, lng: 139.7665076889907 },
      zoom: 6,
      mapId: 'af2da9c1c44ffaf9d071b583',
    });

    // seed値の場所にピンを打つ（青いピン）
    const locations = await fetchDefaultLocations();
    locations.forEach(location => {
      const pinCustom = new PinElement({ 
        glyphColor: 'white',
        background: '#4285F4' // 青色
      });
      new AdvancedMarkerElement({
        map: map,
        position: { lat: location.lat, lng: location.lng },
        content: pinCustom.element,
        title: location.name
      });
    });

    let searchMarkers = [];

    // 既存検索結果マーカーをクリア
    const clearSearchMarkers = () => {
      searchMarkers.forEach(marker => {
        marker.map = null;
      });
      searchMarkers = [];
    };

    // 検索結果をピンで表示（赤いピン）
    const setSearchMarkers = (places, baseLocation = null) => {
      clearSearchMarkers();
      
      if (!places || places.length === 0) {
        console.log('No places to display');
        return;
      }

      const validPlaces = places.filter(place => place.lat && place.lng);
      
      if (validPlaces.length === 0) {
        console.log('No valid coordinates found');
        return;
      }

      // マーカーを作成
      validPlaces.forEach(place => {
        const searchPin = new PinElement({
          glyphColor: 'white',
          background: '#EA4335' // 赤色
        });
        
        const marker = new AdvancedMarkerElement({
          map: map,
          position: { lat: place.lat, lng: place.lng },
          content: searchPin.element,
          title: place.name
        });
        
        // 情報ウィンドウを作成（オプション）
        const infoWindow = new google.maps.InfoWindow({
          content: `
            <div>
              <h3>${place.name}</h3>
              <p>${place.address}</p>
            </div>
          `
        });
        
        // マーカークリック時に情報ウィンドウを表示
        marker.addListener('click', () => {
          infoWindow.open(map, marker);
        });
        
        searchMarkers.push(marker);
      });
      
      // マップの表示を調整
      adjustMapView(validPlaces, baseLocation);
    };

    // マップの表示範囲を検索結果に合わせて調整
    const adjustMapView = (places, baseLocation = null) => {
      if (places.length === 0) return;

      // 常に基準点（選択した場所）を中心にズーム10で表示
      if (baseLocation && baseLocation.lat && baseLocation.lng) {
        console.log(`Setting map center to: ${baseLocation.name} (${baseLocation.lat}, ${baseLocation.lng})`);
        map.setCenter({ lat: baseLocation.lat, lng: baseLocation.lng });
        map.setZoom(10);
      } else {
        console.log('No base location found, using search results for map view');
        
        if (places.length === 1) {
          // 1つの結果の場合：その場所を中心にズーム10で表示
          map.setCenter({ lat: places[0].lat, lng: places[0].lng });
          map.setZoom(10);
        } else {
          // 複数の結果の場合：すべての結果が見えるように範囲を調整
          const bounds = new google.maps.LatLngBounds();
          places.forEach(place => {
            bounds.extend(new google.maps.LatLng(place.lat, place.lng));
          });
          
          map.fitBounds(bounds);
          
          // fitBoundsの後、ズームレベルが高すぎる場合は制限
          google.maps.event.addListenerOnce(map, 'bounds_changed', () => {
            if (map.getZoom() > 12) {
              map.setZoom(12);
            }
          });
        }
      }
    };

    // グローバルに関数を公開して、フォームから呼び出せるようにする
    window.performSearch = async (location, accommodationType, poiType, keyword) => {
      console.log('Performing search with:', { location, accommodationType, poiType, keyword });
      
      const places = await searchLocations(location, accommodationType, poiType, keyword);
      console.log('Search results:', places);
      
      // 検索基準点（選択した場所）の情報を取得
      const baseLocation = await getBaseLocation(location);
      
      setSearchMarkers(places, baseLocation);
    };

    // 検索基準点の情報を取得する関数
    const getBaseLocation = async (locationName) => {
      if (!locationName) {
        console.log('No location name provided');
        return null;
      }
      
      const locations = await fetchDefaultLocations();
      const foundLocation = locations.find(loc => loc.name === locationName);
      
      if (foundLocation) {
        console.log(`Found base location: ${foundLocation.name} at (${foundLocation.lat}, ${foundLocation.lng})`);
      } else {
        console.log(`Base location not found for: ${locationName}`);
      }
      
      return foundLocation;
    };

    // 検索結果をクリアする関数
    window.clearSearch = () => {
      clearSearchMarkers();
      // マップを初期状態に戻す
      map.setCenter({ lat: 35.68125718370711, lng: 139.7665076889907 });
      map.setZoom(6);
    };
  };
}
