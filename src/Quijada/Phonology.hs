module Quijada.Phonology
  ( Phoneme
  , PString
  , phonemes
  , chars
  , consonants
  , vowels
  , phoneme
  , renderP
  , pstring
  , render
  , isConsonant
  , isVowel
  ) where

import qualified Data.Bimap as BM
import Data.Either (lefts, rights)
import Quijada.Error

type PString = [Phoneme]

data Phoneme
  = C CVoicedness CPlace CManner
  | V VRoundedness VPlace VHeight
  deriving (Show, Eq, Ord)

data CVoicedness = Voiced | Unvoiced
  deriving (Show, Eq, Ord)
data CPlace
  = Labial | LabioDental | LabioVelar | ApicoDental | InterDental | ApicoAlveolar
  | Alveolar | AlveolarRetroflex | AlveoloPalatal | Palatal | Velar | Uvular | Glottal | Lateral
  deriving (Show, Eq, Ord)
data CManner = Stop | Fricative | Affricative | Nasal | Tap | Liquid | Approximant
  deriving (Show, Eq, Ord)

data VRoundedness = Rounded | Unrounded
  deriving (Show, Eq, Ord)
data VPlace = Front | Central | Back
  deriving (Show, Eq, Ord)
data VHeight = High | Mid | Low
  deriving (Show, Eq, Ord)

-- Section 1.1: Phonemic Inventory
phonemeChart :: [(Phoneme, Char)]
phonemeChart = [
  -- Consonant
    (C Unvoiced Labial Stop,                'p')
  , (C Voiced Labial Stop,                  'b')
  , (C Unvoiced ApicoDental Stop,           't')
  , (C Voiced ApicoDental Stop,             'd')
  , (C Unvoiced Velar Stop,                 'k')
  , (C Voiced Velar Stop,                   'g')
  , (C Unvoiced Glottal Stop,               '\'')
  , (C Unvoiced LabioDental Fricative,      'f')
  , (C Voiced LabioDental Fricative,        'v')
  , (C Unvoiced InterDental Fricative,      'ţ')
  , (C Voiced InterDental Fricative,        'ḑ')
  , (C Unvoiced ApicoAlveolar Fricative,    's')
  , (C Voiced ApicoAlveolar Fricative,      'z')
  , (C Unvoiced AlveoloPalatal Fricative,   'š')
  , (C Voiced AlveoloPalatal Fricative,     'ž')
  , (C Unvoiced Palatal Fricative,          'ç') 
  , (C Unvoiced Uvular Fricative,           'x')
  , (C Unvoiced Glottal Fricative,          'h')
  , (C Unvoiced Lateral Fricative,          'ļ')
  , (C Unvoiced ApicoAlveolar Affricative,  'c')
  , (C Voiced ApicoAlveolar Affricative,    'ẓ')
  , (C Unvoiced AlveoloPalatal Affricative, 'č')
  , (C Voiced AlveoloPalatal Affricative,   'j')
  , (C Voiced Labial Nasal,                 'm')
  , (C Voiced ApicoDental Nasal,            'n')
  , (C Voiced Velar Nasal,                  'ň')
  , (C Voiced AlveolarRetroflex Tap,        'r')
  , (C Voiced Lateral Liquid,               'l')
  , (C Voiced LabioVelar Approximant,       'w')
  , (C Voiced Palatal Approximant,          'y')
  , (C Voiced Uvular Approximant,           'ř')
  -- Vowels
  , (V Unrounded Front High,                'i')
  , (V Rounded Front High,                  'ü')
  , (V Rounded Back High,                   'u')
  , (V Unrounded Front Mid,                 'e')
  , (V Rounded Front Mid,                   'ö')
  , (V Unrounded Back Mid,                  'ë')
  , (V Rounded Back Mid,                    'o')
  , (V Unrounded Central Low,               'a')
  , (V Unrounded Back Low,                  'ä')
  ]

phonemes :: [Phoneme]
phonemes = map fst phonemeChart

chars :: [Char]
chars = map snd phonemeChart

isConsonant, isVowel :: Phoneme -> Bool
isConsonant p = case p of (C _ _ _) -> True; _ -> False
isVowel p = case p of (V _ _ _) -> True; _ -> False

consonants, vowels :: [Phoneme]
consonants = filter isConsonant phonemes
vowels = filter isVowel phonemes

phonemeMap :: BM.Bimap Phoneme Char
phonemeMap = BM.fromList phonemeChart

phoneme :: Char -> Either Error Phoneme
phoneme c =
  case BM.lookupR c phonemeMap of
    Just p -> Right p
    Nothing -> Left $ UnknownChar c

pstring :: String -> Either [Error] PString
pstring s = sequenceLefts $ map phoneme s

sequenceLefts :: [Either a b] -> Either [a] [b]
sequenceLefts xs =
  case lefts xs of
    [] -> Right $ rights xs
    _ -> Left $ lefts xs

renderP :: Phoneme -> Char
renderP p = maybe (error "broken phoneme chart") id $ BM.lookup p phonemeMap

render :: PString -> String
render ps = map renderP ps
