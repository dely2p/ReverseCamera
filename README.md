# ReverseCamera

- 전면 카메라일 때 실시간 반전화면으로 만들어주는 앱

- 초기 기획으로는 metal을 이용해 실시간 화면 반전을 해줄 계획이었으나
아래 두 줄의 코드만으로로 해결이 가능하여 그 외 다른 기능을 추가하려고 함.

```swift
	self.previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
	self.previewLayer?.connection?.isVideoMirrored = false
```

(기능 추가 예정)