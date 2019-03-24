package status

// The json:* is needed to lowercase the resulting api
type ApplicationInfo struct {
	Version       string `json:"version"`
	Description   string `json:"description"`
	Lastcommitsha string `json:"lastcommitsha"`
}

type Response struct {
	Myapplication *ApplicationInfo `json:"myapplication"`
}
