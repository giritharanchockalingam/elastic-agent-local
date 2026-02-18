# Voice-Enabled AI Assistant

The AI Assistant can now listen and speak! This document explains how to enable and use voice capabilities.

## Features

### 🎤 Voice Input (Speech-to-Text)
- Click the microphone button to start voice input
- Speak your question naturally
- The assistant automatically converts your speech to text
- Works in Chrome, Edge, and Safari (WebKit-based browsers)

### 🔊 Voice Output (Text-to-Speech)
- Assistant responses are automatically spoken aloud
- Toggle voice output on/off with the volume button
- Uses your browser's native text-to-speech engine
- Supports multiple languages and voices

## Browser Support

### Voice Input (Speech Recognition)
- ✅ **Chrome/Edge (Desktop)**: Full support
- ✅ **Chrome (Android)**: Full support (Android 6.0+)
- ✅ **Safari (macOS)**: Full support (macOS 10.15+)
- ✅ **Safari (iOS)**: Full support (iOS 13+)
- ❌ **Firefox**: Not supported (uses different API)
- ❌ **Opera**: Limited support

### Voice Output (Text-to-Speech)
- ✅ **All modern browsers**: Full support (Desktop & Mobile)

### Mobile Support
- ✅ **iOS Safari**: Full voice support (iOS 13+)
- ✅ **Android Chrome**: Full voice support (Android 6.0+)
- ✅ **Responsive Design**: Optimized for mobile screens
- ✅ **Touch-Friendly**: Large touch targets (44px minimum)
- ✅ **Full-Screen on Mobile**: Chat window adapts to mobile screen size

## How to Use

### Option 1: Replace Existing Component (Recommended)

Replace `AIAssistant` with `AIAssistantVoice` in your layout:

```tsx
// Before
import { AIAssistant } from '@/components/AIAssistant';

// After
import { AIAssistantVoice } from '@/components/AIAssistantVoice';

// In your component
<AIAssistantVoice />
```

### Option 2: Add Voice Toggle to Existing Component

You can add voice capabilities to the existing `AIAssistant` component by importing the hooks:

```tsx
import { useVoiceRecognition } from '@/hooks/useVoiceRecognition';
import { useTextToSpeech } from '@/hooks/useTextToSpeech';
```

## Implementation Details

### Hooks Created

1. **`useVoiceRecognition`** (`src/hooks/useVoiceRecognition.ts`)
   - Handles speech-to-text conversion
   - Manages microphone permissions
   - Provides real-time transcript updates
   - Auto-submits when speech recognition completes

2. **`useTextToSpeech`** (`src/hooks/useTextToSpeech.ts`)
   - Converts text responses to speech
   - Supports voice selection, pitch, rate, and volume
   - Handles speech queue management

### Components Created

- **`AIAssistantVoice`** (`src/components/AIAssistantVoice.tsx`)
  - Enhanced version of `AIAssistant` with voice capabilities
  - Includes microphone button for voice input
  - Includes volume toggle for voice output
  - Maintains all existing functionality

## Privacy & Permissions

### Microphone Access
- Browser will prompt for microphone permission on first use
- Permission is required for voice input
- **Mobile**: May require additional permission in device settings
- No audio data is stored or transmitted (only text transcript)
- Users can deny permission and use text input instead

### Mobile Permissions
- **iOS**: Settings → Safari → Microphone (or in-app permission)
- **Android**: Settings → Apps → [Your App] → Permissions → Microphone
- First-time users will see a browser permission dialog

### Data Privacy
- Voice recognition happens locally in the browser
- Only the text transcript is sent to the AI Assistant
- No audio recordings are stored or transmitted
- Text-to-speech is generated locally in the browser

## Configuration

### Voice Recognition Settings

You can customize voice recognition in `useVoiceRecognition`:

```tsx
const {
  isListening,
  transcript,
  startListening,
  stopListening,
} = useVoiceRecognition({
  continuous: false,        // Auto-stop after speech ends
  interimResults: true,     // Show real-time transcript
  lang: 'en-US',           // Language code
  onResult: (text) => {    // Callback when speech completes
    console.log('Recognized:', text);
  },
  onError: (error) => {    // Error handler
    console.error(error);
  },
});
```

### Text-to-Speech Settings

You can customize TTS in `useTextToSpeech`:

```tsx
const { speak, stop, isSpeaking } = useTextToSpeech({
  lang: 'en-US',      // Language
  pitch: 1,          // 0-2 (default: 1)
  rate: 1,           // 0.1-10 (default: 1)
  volume: 0.9,       // 0-1 (default: 1)
  voice: null,       // Specific voice object
});
```

## Troubleshooting

### Voice Input Not Working

1. **Check browser support**: Use Chrome, Edge, or Safari
2. **Check permissions**: Ensure microphone access is granted
   - **Mobile**: Check both browser and device settings
3. **Check HTTPS**: Voice recognition requires HTTPS (or localhost)
4. **Check microphone**: Ensure microphone is connected and working
5. **Mobile-specific**: 
   - Ensure device microphone is not muted
   - Check if other apps are using the microphone
   - Try closing and reopening the browser tab

### Mobile-Specific Issues

**"Permission denied" on iOS**
- Go to Settings → Safari → Microphone → Enable
- Or grant permission when browser prompts

**"Permission denied" on Android**
- Go to Settings → Apps → Chrome → Permissions → Microphone → Allow
- Or grant permission when browser prompts

**Voice recognition stops immediately**
- This is normal on mobile - recognition auto-stops after speech ends
- Tap the microphone button again to continue

**Poor recognition accuracy on mobile**
- Speak clearly and close to the microphone
- Reduce background noise
- Ensure good internet connection (Chrome uses cloud service)

### Voice Output Not Working

1. **Check browser support**: All modern browsers support TTS
2. **Check volume**: Ensure system volume is not muted
3. **Check toggle**: Ensure voice output is enabled (volume icon)

### Common Issues

**"Microphone not accessible"**
- Grant microphone permission in browser settings
- Check if another app is using the microphone
- Try refreshing the page

**"Speech recognition error"**
- Ensure you're on HTTPS or localhost
- Check internet connection (Chrome uses cloud service)
- Try speaking more clearly or closer to microphone

**"No speech detected"**
- Speak louder or closer to microphone
- Check microphone is not muted
- Try in a quieter environment

## Future Enhancements

Potential improvements:
- [ ] Multi-language support with auto-detection
- [ ] Voice activity detection (VAD) for better accuracy
- [ ] Custom wake words
- [ ] Voice commands for navigation
- [ ] Integration with cloud TTS for better voices
- [ ] Voice profiles for different users

## Security Considerations

1. **HTTPS Required**: Voice recognition requires secure connection
2. **Permission Handling**: Always request permission gracefully
3. **Error Handling**: Provide clear error messages
4. **Privacy**: No audio data is stored or transmitted
5. **Fallback**: Always provide text input as fallback

## Performance

- **Voice Recognition**: Minimal impact (browser-native)
- **Text-to-Speech**: Minimal impact (browser-native)
- **Network**: No additional network requests
- **Battery**: Slightly higher battery usage when actively listening

## Accessibility

Voice capabilities improve accessibility:
- ✅ Hands-free interaction
- ✅ Visual impairment support
- ✅ Motor impairment support
- ✅ Multitasking support

## Example Usage

```tsx
import { AIAssistantVoice } from '@/components/AIAssistantVoice';

function MyPage() {
  return (
    <div>
      {/* Your page content */}
      <AIAssistantVoice />
    </div>
  );
}
```

The voice-enabled assistant will automatically:
1. Show microphone button for voice input
2. Show volume toggle for voice output
3. Handle all permissions and errors gracefully
4. Fall back to text input if voice is unavailable
